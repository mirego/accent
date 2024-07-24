defmodule AccentTest.SyncControllerMock do
  @moduledoc false
  use Accent.ConnCase

  import Mock

  alias Accent.AccessToken
  alias Accent.Collaborator
  alias Accent.Language
  alias Accent.Project
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
    {:ok, [access_token: access_token, project: project, language: french_language]}
  end

  test "sync with failure", %{access_token: access_token, conn: conn, project: project, language: language} do
    body = %{
      file: file(),
      project_id: project.id,
      language: language.slug,
      document_format: "json",
      document_path: "simple"
    }

    with_mock(Movement.Persisters.ProjectSync, persist: fn _ -> {:error, "oups"} end) do
      response =
        conn
        |> put_req_header("authorization", "Bearer #{access_token.token}")
        |> post(sync_path(conn, []), body)

      assert response.status == 422
    end
  end
end
