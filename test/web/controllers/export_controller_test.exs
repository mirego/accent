defmodule AccentTest.ExportController do
  use Accent.ConnCase

  alias Accent.{
    Document,
    Language,
    Project,
    Repo,
    Revision,
    Translation,
    User,
    Version
  }

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    french_language = %Language{name: "french", slug: Ecto.UUID.generate()} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()

    revision = %Revision{language_id: french_language.id, project_id: project.id, master: true} |> Repo.insert!()

    {:ok, [user: user, project: project, revision: revision, language: french_language]}
  end

  test "export inline", %{conn: conn, project: project, revision: revision, language: language} do
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar", document_id: document.id} |> Repo.insert!()

    params = %{inline_render: true, project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}
    response = get(conn, export_path(conn, [], params))

    assert get_resp_header(response, "content-type") == ["text/plain"]

    assert response.resp_body == """
           {
             "ok": "bar"
           }
           """
  end

  test "export basic", %{conn: conn, project: project, revision: revision, language: language} do
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar", document_id: document.id} |> Repo.insert!()

    params = %{project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}
    response = get(conn, export_path(conn, [], params))

    assert get_resp_header(response, "content-disposition") == ["inline; filename=\"#{document.path}\""]

    assert response.resp_body == """
           {
             "ok": "bar"
           }
           """
  end

  test "export unknown language for the project", %{conn: conn, project: project} do
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    language = %Language{name: "chinese", slug: Ecto.UUID.generate()} |> Repo.insert!()

    params = %{project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}
    response = get(conn, export_path(conn, [], params))

    assert response.status == 404
  end

  test "export document", %{conn: conn, project: project, revision: revision, language: language} do
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    other_document = %Document{project_id: project.id, path: "test3", format: "json"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar", document_id: document.id} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "test", corrected_text: "foo", proposed_text: "foo", document_id: other_document.id} |> Repo.insert!()

    params = %{project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}

    response =
      conn
      |> get(export_path(conn, [], params))

    assert get_resp_header(response, "content-disposition") == ["inline; filename=\"#{document.path}\""]

    assert response.resp_body == """
           {
             "ok": "bar"
           }
           """
  end

  test "export unknown document", %{conn: conn, project: project, language: language} do
    params = %{project_id: project.id, language: language.slug, document_format: "json", document_path: "foo"}
    response = get(conn, export_path(conn, [], params))

    assert response.status == 404
  end

  test "export version", %{conn: conn, user: user, project: project, revision: revision, language: language} do
    version = %Version{project_id: project.id, user_id: user.id, name: "Current", tag: "master"} |> Repo.insert!()
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar", document_id: document.id} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "test", corrected_text: "foo", proposed_text: "foo", document_id: document.id, version_id: version.id} |> Repo.insert!()

    params = %{version: "master", project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}

    response =
      conn
      |> get(export_path(conn, [], params))

    assert response.resp_body == """
           {
             "test": "foo"
           }
           """
  end

  test "export without version", %{conn: conn, user: user, project: project, revision: revision, language: language} do
    version = %Version{project_id: project.id, user_id: user.id, name: "Current", tag: "master"} |> Repo.insert!()
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar", document_id: document.id} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "test", corrected_text: "foo", proposed_text: "foo", document_id: document.id, version_id: version.id} |> Repo.insert!()

    params = %{project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}
    response = get(conn, export_path(conn, [], params))

    assert response.resp_body == """
           {
             "ok": "bar"
           }
           """
  end

  test "export with unknown version", %{conn: conn, project: project, language: language} do
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()

    params = %{version: "foo", project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}
    response = get(conn, export_path(conn, [], params))

    assert response.status == 404
  end

  test "export with order", %{conn: conn, project: project, revision: revision, language: language} do
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar", document_id: document.id} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "test", corrected_text: "foo", proposed_text: "foo", document_id: document.id} |> Repo.insert!()

    params = %{order_by: "key", project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}
    response = get(conn, export_path(conn, [], params))

    assert response.resp_body == """
           {
             "ok": "bar",
             "test": "foo"
           }
           """
  end

  test "export with default order", %{conn: conn, project: project, revision: revision, language: language} do
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar", document_id: document.id, file_index: 2} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "test", corrected_text: "foo", proposed_text: "foo", document_id: document.id, file_index: 1} |> Repo.insert!()

    params = %{order_by: "", project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}
    response = get(conn, export_path(conn, [], params))

    assert response.resp_body == """
           {
             "test": "foo",
             "ok": "bar"
           }
           """
  end

  test "export with language overrides", %{conn: conn, project: project, revision: revision} do
    revision = Repo.update!(Ecto.Changeset.change(revision, %{slug: "testtest"}))
    document = %Document{project_id: project.id, path: "test2", format: "rails_yml"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar", document_id: document.id, file_index: 2} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "test", corrected_text: "foo", proposed_text: "foo", document_id: document.id, file_index: 1} |> Repo.insert!()

    params = %{order_by: "", project_id: project.id, language: revision.slug, document_format: document.format, document_path: document.path}
    response = get(conn, export_path(conn, [], params))

    assert response.resp_body == """
           "testtest":
             "test": "foo"
             "ok": "bar"
           """
  end
end
