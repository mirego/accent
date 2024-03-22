defmodule AccentTest.SyncController do
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
    Factory.insert(Revision, language_id: french_language.id, project_id: project.id, master: true)
    {:ok, [access_token: access_token, user: user, project: project, language: french_language]}
  end

  test "sync with operations", %{
    user: user,
    access_token: access_token,
    conn: conn,
    project: project,
    language: language
  } do
    body = %{
      file: file(),
      project_id: project.id,
      language: language.slug,
      document_format: "json",
      document_path: "simple"
    }

    response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> post(sync_path(conn, []), body)

    assert response.status == 200

    assert_enqueued(worker: Movement.Persisters.ProjectHookWorker)

    assert Enum.map(Repo.all(Document), &Map.get(&1, :path)) == ["simple"]

    new_operations = Repo.all(from(o in Operation, where: [action: ^"new"]))
    sync_operation = Repo.one(from(o in Operation, where: [action: ^"sync"]))

    assert length(new_operations) == 3
    assert sync_operation.user_id == user.id
    assert sync_operation.project_id == project.id

    response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> post(sync_path(conn, []), body)

    assert response.status == 200
  end
end
