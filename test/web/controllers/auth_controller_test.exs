defmodule AccentTest.AuthenticationController do
  use Accent.ConnCase

  alias Accent.AccessToken
  alias Accent.AuthController
  alias Accent.Repo
  alias Accent.User

  test "create responds with error when invalid params", %{conn: conn} do
    conn = AuthController.callback(conn, nil)

    assert redirected_to(conn, 302) == "/"
  end

  test "create responds with valid dummy params", %{conn: conn} do
    conn =
      conn
      |> assign(:ueberauth_auth, %{provider: :dummy, info: %{email: "dummy@test.com"}})
      |> AuthController.callback(nil)

    user = Repo.get_by(User, email: "dummy@test.com")
    global_token = Repo.get_by(AccessToken, user_id: user.id, global: true)

    assert global_token
    assert Repo.get_by(AccessToken, user_id: user.id, global: false)
    assert redirected_to(conn, 302) == "/app/projects"
  end

  test "create responds with valid google params", %{conn: conn} do
    conn =
      conn
      |> assign(:ueberauth_auth, %{provider: :google, info: %{name: "Dummy", email: "dummy@test.com", image: nil}})
      |> AuthController.callback(nil)

    user = Repo.get_by(User, email: "dummy@test.com")
    assert Repo.get_by(AccessToken, user_id: user.id, global: false)
    assert user.fullname === "Dummy"
    assert redirected_to(conn, 302) == "/app/projects"
  end

  test "logout clears session and redirects to root", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{user_id: "some-user-id"})
      |> AuthController.logout(nil)

    assert redirected_to(conn, 302) == "/"
  end
end
