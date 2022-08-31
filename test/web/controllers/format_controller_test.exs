defmodule AccentTest.FormatController do
  use Accent.ConnCase

  alias Accent.{
    AccessToken,
    Project,
    Repo,
    User
  }

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    access_token = %AccessToken{user_id: user.id, token: "test-token"} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()

    {:ok, [user: user, project: project, access_token: access_token]}
  end

  test "format inline", %{conn: conn, project: project, access_token: access_token} do
    file = %Plug.Upload{content_type: "application/json", filename: "simple.json", path: "test/support/formatter/json/simple.json"}
    body = %{inline_render: true, project_id: project.id, language: "fr", document_format: "json", file: file}

    response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> post(format_path(conn, :format), body)

    assert response.resp_body == """
           {
             "test": "F",
             "test2": "D",
             "test3": "New history please"
           }
           """
  end

  test "format order_by", %{conn: conn, project: project, access_token: access_token} do
    file = %Plug.Upload{content_type: "application/json", filename: "simple.json", path: "test/support/formatter/json/unordered.json"}
    body = %{inline_render: true, order_by: "key", project_id: project.id, language: "fr", document_format: "json", file: file}

    response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> post(format_path(conn, :format), body)

    assert response.resp_body == """
           {
             "a": "2",
             "b": "3",
             "c": "1"
           }
           """
  end
end
