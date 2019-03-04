defmodule AccentTest.ExportJIPTController do
  use Accent.ConnCase

  alias Accent.{
    Document,
    Language,
    Project,
    Repo,
    Revision,
    Translation,
    User
  }

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    french_language = %Language{name: "french", slug: Ecto.UUID.generate()} |> Repo.insert!()
    project = %Project{name: "My project"} |> Repo.insert!()

    revision = %Revision{language_id: french_language.id, project_id: project.id, master: true} |> Repo.insert!()

    {:ok, [user: user, project: project, revision: revision, language: french_language]}
  end

  test "export inline", %{conn: conn, project: project, revision: revision, language: language} do
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar", document_id: document.id} |> Repo.insert!()

    params = %{inline_render: true, project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}

    response =
      conn
      |> get(export_jipt_path(conn, [], params))

    assert get_resp_header(response, "content-type") == ["text/plain"]

    assert response.resp_body == """
           {
             "ok": "{^ok@test2}"
           }
           """
  end

  test "export basic", %{conn: conn, project: project, revision: revision, language: language} do
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar", document_id: document.id} |> Repo.insert!()

    params = %{project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}

    response =
      conn
      |> get(export_jipt_path(conn, [], params))

    assert get_resp_header(response, "content-disposition") == ["inline; filename=\"#{document.path}\""]

    assert response.resp_body == """
           {
             "ok": "{^ok@test2}"
           }
           """
  end

  test "export document", %{conn: conn, project: project, revision: revision, language: language} do
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    other_document = %Document{project_id: project.id, path: "test3", format: "json"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar", document_id: document.id} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "test", corrected_text: "foo", proposed_text: "foo", document_id: other_document.id} |> Repo.insert!()

    params = %{project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}

    response =
      conn
      |> get(export_jipt_path(conn, [], params))

    assert get_resp_header(response, "content-disposition") == ["inline; filename=\"#{document.path}\""]

    assert response.resp_body == """
           {
             "ok": "{^ok@test2}"
           }
           """
  end

  test "export unknown document", %{conn: conn, project: project, language: language} do
    params = %{project_id: project.id, language: language.slug, document_format: "json", document_path: "foo"}

    response =
      conn
      |> get(export_jipt_path(conn, [], params))

    assert response.status == 404
  end
end
