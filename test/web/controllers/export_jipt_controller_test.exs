defmodule AccentTest.ExportJIPTController do
  use Accent.ConnCase

  alias Accent.Document
  alias Accent.Language
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User

  setup do
    user = Factory.insert(User)
    french_language = Factory.insert(Language)
    project = Factory.insert(Project)

    revision = Factory.insert(Revision, language_id: french_language.id, project_id: project.id, master: true)

    {:ok, [user: user, project: project, revision: revision, language: french_language]}
  end

  test "export inline", %{conn: conn, project: project, revision: revision, language: language} do
    document = Factory.insert(Document, project_id: project.id, path: "test2", format: "json")

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "ok",
      corrected_text: "bar",
      proposed_text: "bar",
      document_id: document.id
    )

    params = %{
      inline_render: true,
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response = get(conn, export_jipt_path(conn, [], params))

    assert get_resp_header(response, "content-type") == ["text/plain"]

    assert response.resp_body == """
           {
             "ok": "{^ok@test2}"
           }
           """
  end

  test "export basic", %{conn: conn, project: project, revision: revision, language: language} do
    document = Factory.insert(Document, project_id: project.id, path: "test2", format: "json")

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "ok",
      corrected_text: "bar",
      proposed_text: "bar",
      document_id: document.id
    )

    params = %{
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response = get(conn, export_jipt_path(conn, [], params))

    assert get_resp_header(response, "content-disposition") == ["inline; filename=\"#{document.path}\""]

    assert response.resp_body == """
           {
             "ok": "{^ok@test2}"
           }
           """
  end

  test "export document", %{conn: conn, project: project, revision: revision, language: language} do
    document = Factory.insert(Document, project_id: project.id, path: "test2", format: "json")
    other_document = Factory.insert(Document, project_id: project.id, path: "test3", format: "json")

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "ok",
      corrected_text: "bar",
      proposed_text: "bar",
      document_id: document.id
    )

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "test",
      corrected_text: "foo",
      proposed_text: "foo",
      document_id: other_document.id
    )

    params = %{
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response = get(conn, export_jipt_path(conn, [], params))

    assert get_resp_header(response, "content-disposition") == ["inline; filename=\"#{document.path}\""]

    assert response.resp_body == """
           {
             "ok": "{^ok@test2}"
           }
           """
  end

  test "export unknown document", %{conn: conn, project: project, language: language} do
    params = %{project_id: project.id, language: language.slug, document_format: "json", document_path: "foo"}

    response = get(conn, export_jipt_path(conn, [], params))

    assert response.status == 404
  end

  if Langue.Formatter.Rails.enabled?() do
    test "export with language overrides", %{conn: conn, project: project, revision: revision, language: language} do
      revision = Repo.update!(Ecto.Changeset.change(revision, %{slug: "testtest"}))
      document = Factory.insert(Document, project_id: project.id, path: "test2", format: "rails_yml")

      Factory.insert(Translation,
        revision_id: revision.id,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar",
        document_id: document.id,
        file_index: 2
      )

      Factory.insert(Translation,
        revision_id: revision.id,
        key: "test",
        corrected_text: "foo",
        proposed_text: "foo",
        document_id: document.id,
        file_index: 1
      )

      params = %{
        order_by: "",
        project_id: project.id,
        language: language.slug,
        document_format: document.format,
        document_path: document.path
      }

      response = get(conn, export_jipt_path(conn, [], params))

      assert response.resp_body == """
             "testtest":
               "ok": "{^ok@test2}"
               "test": "{^test@test2}"
             """
    end
  end
end
