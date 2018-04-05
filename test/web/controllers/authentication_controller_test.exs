defmodule AccentTest.AuthenticationController do
  use Accent.ConnCase

  test "create responds with error when invalid params", %{conn: conn} do
    response =
      conn
      |> post(authentication_path(conn, :create))
      |> json_response(401)

    assert response == %{"error" => "Invalid params"}
  end

  test "create responds with authenticated user", %{conn: conn} do
    response =
      conn
      |> post(authentication_path(conn, :create), %{uid: "test@example.com", provider: "dummy"})
      |> json_response(200)

    assert get_in(response, ["user", "email"]) == "test@example.com"
    assert get_in(response, ["token"]) != nil
  end

  test "create responds with error on unkown provider", %{conn: conn} do
    response =
      conn
      |> post(authentication_path(conn, :create), %{uid: "test@example.com", provider: "test"})
      |> json_response(401)

    assert response == %{"error" => %{"provider" => "unknown"}}
  end
end
