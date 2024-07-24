defmodule AccentTest.MergeController do
  use Accent.ConnCase

  import Ecto.Query, only: [from: 2]

  alias Accent.AccessToken
  alias Accent.Collaborator
  alias Accent.Document
  alias Accent.Language
  alias Accent.Operation
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User

  def file(filename \\ "simple.json") do
    %Plug.Upload{content_type: "application/json", filename: filename, path: "test/support/formatter/json/simple.json"}
  end

  setup do
    user = Factory.insert(User)
    access_token = Factory.insert(AccessToken, user_id: user.id, token: "test-token")
    french_language = Factory.insert(Language)
    project = Factory.insert(Project)

    Factory.insert(Collaborator, project_id: project.id, user_id: user.id, role: "admin")
    revision = Factory.insert(Revision, language_id: french_language.id, project_id: project.id, master: true)

    {:ok, [access_token: access_token, user: user, project: project, revision: revision, language: french_language]}
  end

  test "merge default", %{
    user: user,
    access_token: access_token,
    conn: conn,
    project: project,
    revision: revision,
    language: language
  } do
    document = Factory.insert(Document, project_id: project.id, path: "test2", format: "json")

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "test",
      conflicted: true,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    body = %{
      file: file(),
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> post(merge_path(conn, []), body)

    assert response.status == 200

    assert_enqueued(worker: Movement.Persisters.ProjectHookWorker)

    merge_on_proposed_operation = Repo.one(from(o in Operation, where: [action: ^"merge_on_proposed"]))
    merge_operation = Repo.one(from(o in Operation, where: [action: ^"merge"]))

    assert merge_on_proposed_operation.batch_operation_id == merge_operation.id
    assert merge_operation.user_id == user.id
    assert merge_operation.revision_id == revision.id
  end

  test "merge passive", %{
    access_token: access_token,
    conn: conn,
    project: project,
    revision: revision,
    language: language
  } do
    document = Factory.insert(Document, project_id: project.id, path: "test2", format: "json")

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "test",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    body = %{
      file: file(),
      merge_type: "passive",
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> post(merge_path(conn, []), body)

    assert response.status == 200

    merge_on_proposed_operation = Repo.one(from(o in Operation, where: [action: ^"merge_on_proposed"]))
    merge_operation = Repo.one(from(o in Operation, where: [action: ^"merge"]))

    assert merge_on_proposed_operation == nil
    assert merge_operation == nil
  end

  test "merge force", %{
    user: user,
    access_token: access_token,
    conn: conn,
    project: project,
    revision: revision,
    language: language
  } do
    document = Factory.insert(Document, project_id: project.id, path: "test2", format: "json")

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "test",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "modified",
      document_id: document.id
    )

    body = %{
      file: file(),
      merge_type: "force",
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> post(merge_path(conn, []), body)

    assert response.status == 200

    assert_enqueued(worker: Movement.Persisters.ProjectHookWorker)

    merge_on_corrected_force_operation = Repo.one(from(o in Operation, where: [action: ^"merge_on_corrected_force"]))
    merge_operation = Repo.one(from(o in Operation, where: [action: ^"merge"]))

    assert merge_on_corrected_force_operation.batch_operation_id == merge_operation.id
    assert merge_on_corrected_force_operation.text == "F"
    assert merge_operation.user_id == user.id
    assert merge_operation.revision_id == revision.id
  end

  test "merge old route", %{
    user: user,
    access_token: access_token,
    conn: conn,
    project: project,
    revision: revision,
    language: language
  } do
    document = Factory.insert(Document, project_id: project.id, path: "test2", format: "json")

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "test",
      conflicted: true,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    body = %{
      file: file(),
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> post("/merge", body)

    assert response.status == 200

    assert_enqueued(worker: Movement.Persisters.ProjectHookWorker)

    merge_on_proposed_operation = Repo.one(from(o in Operation, where: [action: ^"merge_on_proposed"]))
    merge_operation = Repo.one(from(o in Operation, where: [action: ^"merge"]))

    assert merge_on_proposed_operation.batch_operation_id == merge_operation.id
    assert merge_operation.user_id == user.id
    assert merge_operation.revision_id == revision.id
  end
end
