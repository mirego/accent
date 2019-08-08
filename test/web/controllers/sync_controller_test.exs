defmodule AccentTest.SyncController do
  use Accent.ConnCase

  import Ecto.Query, only: [from: 2]
  import Mox
  setup :verify_on_exit!

  alias Accent.{
    AccessToken,
    Collaborator,
    Document,
    Language,
    Operation,
    Project,
    Repo,
    Revision,
    User
  }

  @user %User{email: "test@test.com"}

  def file(filename \\ "simple.json") do
    %Plug.Upload{content_type: "application/json", filename: filename, path: "test/support/formatter/json/simple.json"}
  end

  setup do
    user = Repo.insert!(@user)
    access_token = %AccessToken{user_id: user.id, token: "test-token"} |> Repo.insert!()
    french_language = %Language{name: "french", slug: Ecto.UUID.generate()} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()

    %Collaborator{project_id: project.id, user_id: user.id, role: "admin"} |> Repo.insert!()
    %Revision{language_id: french_language.id, project_id: project.id, master: true} |> Repo.insert!()

    {:ok, [access_token: access_token, user: user, project: project, language: french_language]}
  end

  test "sync with operations", %{user: user, access_token: access_token, conn: conn, project: project, language: language} do
    body = %{file: file(), project_id: project.id, language: language.slug, document_format: "json", document_path: "simple"}

    Accent.Hook.BroadcasterMock
    |> expect(:notify, fn _ -> :ok end)

    response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> post(sync_path(conn, []), body)

    assert response.status == 200

    assert Enum.map(Repo.all(Document), &Map.get(&1, :path)) == ["simple"]

    new_operations = from(o in Operation, where: [action: ^"new"]) |> Repo.all()
    sync_operation = from(o in Operation, where: [action: ^"sync"]) |> Repo.one()

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
