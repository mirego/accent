defmodule AccentTest.LintController do
  use Accent.ConnCase

  alias Accent.AccessToken
  alias Accent.Collaborator
  alias Accent.Document
  alias Accent.Language
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.User

  @user %User{email: "test@test.com"}

  def file(filename \\ "simple.json") do
    %Plug.Upload{content_type: "application/json", filename: filename, path: "test/support/formatter/json/lint.json"}
  end

  setup do
    user = Repo.insert!(@user)
    access_token = Repo.insert!(%AccessToken{user_id: user.id, token: "test-token"})
    french_language = Repo.insert!(%Language{name: "french", slug: Ecto.UUID.generate()})
    project = Repo.insert!(%Project{main_color: "#f00", name: "My project"})

    Repo.insert!(%Collaborator{project_id: project.id, user_id: user.id, role: "admin"})
    revision = Repo.insert!(%Revision{language_id: french_language.id, project_id: project.id, master: true})

    {:ok, [access_token: access_token, user: user, project: project, revision: revision, language: french_language]}
  end

  test "lint document", %{access_token: access_token, conn: conn, project: project, language: language} do
    document = Repo.insert!(%Document{project_id: project.id, path: "test2", format: "json"})

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
      |> post(lint_path(conn, :lint), body)
      |> json_response(200)

    assert response["data"]["lint_translations"] ===
             [
               %{
                 "comment" => nil,
                 "id" => nil,
                 "index" => 1,
                 "key" => "test",
                 "locked" => false,
                 "master" => true,
                 "messages" => [
                   %{
                     "check" => "leading_spaces",
                     "replacement" => %{"label" => "leading", "value" => "leading"},
                     "text" => " leading"
                   }
                 ],
                 "placeholders" => [],
                 "plural" => false,
                 "text" => " leading"
               }
             ]
  end
end
