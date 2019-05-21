defmodule AccentTest.AuthenticationController do
  use Accent.ConnCase

  alias Accent.{AccessToken, AuthController, Repo, User}

  test "create responds with error when invalid params", %{conn: conn} do
    conn = AuthController.callback(conn, nil)

    assert redirected_to(conn, 302) == "http://localhost:4000"
  end

  test "create responds with valid dummy params", %{conn: conn} do
    conn =
      conn
      |> assign(:ueberauth_auth, %{provider: :dummy, info: %{email: "dummy@test.com"}})
      |> AuthController.callback(nil)

    user = Repo.get_by(User, email: "dummy@test.com")
    token = Repo.get_by(AccessToken, user_id: user.id)
    assert redirected_to(conn, 302) =~ "http://localhost:4000?token=#{token.token}"
  end

  test "create responds with valid google params", %{conn: conn} do
    conn =
      conn
      |> assign(:ueberauth_auth, %{provider: :google, info: %{name: "Dummy", email: "dummy@test.com", image: nil}})
      |> AuthController.callback(nil)

    user = Repo.get_by(User, email: "dummy@test.com")
    token = Repo.get_by(AccessToken, user_id: user.id)
    assert user.fullname === "Dummy"
    assert redirected_to(conn, 302) =~ "http://localhost:4000?token=#{token.token}"
  end
end
