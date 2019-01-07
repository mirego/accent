defmodule AccentTest.UserSocket do
  use Accent.ChannelCase, async: true

  alias Accent.{
    AccessToken,
    Repo,
    User,
    UserSocket
  }

  setup do
    user = Repo.insert!(%User{email: "test@test.com"})

    {:ok, user: user}
  end

  test "id", %{user: user} do
    socket = socket(UserSocket, "autenticated-user", %{user: user})
    id = UserSocket.id(socket)

    assert id === "users:#{user.id}"
  end

  test "connect with valid token", %{user: user} do
    access_token = %AccessToken{user_id: user.id, token: "test-token"} |> Repo.insert!()

    socket = socket(UserSocket, "nonautenticated-user", %{})
    {:ok, socket} = UserSocket.connect(%{"token" => "Bearer #{access_token.token}"}, socket)

    assert socket.assigns[:user].id === user.id
  end

  test "connect with invalid token" do
    socket = socket(UserSocket, "nonautenticated-user", %{})
    assert UserSocket.connect(%{"token" => "Bearer foo"}, socket) === :error
  end

  test "connect without token" do
    socket = socket(UserSocket, "nonautenticated-user", %{})
    assert UserSocket.connect(%{"token-typo" => "Bearer foo"}, socket) === :error
  end
end
