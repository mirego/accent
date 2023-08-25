defmodule AccentTest.FormatController do
  use Accent.ConnCase

  alias Accent.{
    AccessToken,
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

  test "format order_by same as export", %{conn: conn, project: project, access_token: access_token} do
    french_language = %Language{name: "french", slug: Ecto.UUID.generate()} |> Repo.insert!()
    revision = %Revision{language_id: french_language.id, project_id: project.id, master: true} |> Repo.insert!()

    file = %Plug.Upload{content_type: "application/json", filename: "simple.json", path: "test/support/formatter/json/ordering.json"}
    body = %{inline_render: true, order_by: "key", project_id: project.id, language: french_language.slug, document_format: "json", file: file}

    format_response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> post(format_path(conn, :format), body)

    document = %Document{project_id: project.id, path: "ordering", format: "json"} |> Repo.insert!()
    params = %{order_by: "key", project_id: project.id, language: french_language.slug, document_format: "json", document_path: "ordering"}
    content = Jason.decode!(File.read!(file.path))

    for {key, value} <- content do
      %Translation{revision_id: revision.id, key: key, corrected_text: value, proposed_text: value, document_id: document.id} |> Repo.insert!()
    end

    export_response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> get(export_path(conn, [], params))

    assert format_response.resp_body == export_response.resp_body
  end
end
