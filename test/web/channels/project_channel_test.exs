defmodule AccentTest.ProjectChannel do
  @moduledoc false
  use Accent.ChannelCase, async: true

  alias Accent.AccessToken
  alias Accent.Collaborator
  alias Accent.Project
  alias Accent.User
  alias Accent.UserSocket

  setup do
    user = Factory.insert(User, email: "test@test.com")
    project = Factory.insert(Project)
    access_token = Factory.insert(AccessToken, user_id: user.id, token: "test-token")
    Factory.insert(Collaborator, project_id: project.id, user_id: user.id, role: "admin")
    socket = socket(UserSocket, "will-autenticated-user", %{})
    {:ok, socket} = UserSocket.connect(%{"token" => "Bearer #{access_token.token}"}, socket)

    {:ok, socket: socket, user: user, project: project}
  end

  test "join with valid user", %{socket: socket, project: project} do
    {:ok, _, socket} = subscribe_and_join(socket, "projects:#{project.id}", %{})

    assert socket.channel === Accent.ProjectChannel
  end

  test "join with unauthenticated user", %{project: project} do
    socket = socket(UserSocket, "unauthorized-user", %{})

    assert subscribe_and_join(socket, "projects:#{project.id}", %{}) === {:error, %{reason: "unauthorized"}}
  end

  test "join with unauthorized user", %{project: project} do
    user = Factory.insert(User, email: "test2@test.com")
    access_token = Factory.insert(AccessToken, user_id: user.id, token: "test-token-2")

    socket = socket(UserSocket, "unauthorized-user", %{})
    {:ok, socket} = UserSocket.connect(%{"token" => "Bearer #{access_token.token}"}, socket)

    assert subscribe_and_join(socket, "projects:#{project.id}", %{}) === {:error, %{reason: "unauthorized"}}
  end
end
