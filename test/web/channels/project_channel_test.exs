defmodule AccentTest.ProjectChannel do
  use Accent.ChannelCase, async: true

  alias Accent.{
    AccessToken,
    Collaborator,
    Project,
    Repo,
    User,
    UserSocket
  }

  setup do
    user = Repo.insert!(%User{email: "test@test.com"})
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()
    access_token = %AccessToken{user_id: user.id, token: "test-token"} |> Repo.insert!()
    %Collaborator{project_id: project.id, user_id: user.id, role: "admin"} |> Repo.insert!()

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
    user = Repo.insert!(%User{email: "test2@test.com"})
    access_token = %AccessToken{user_id: user.id, token: "test-token-2"} |> Repo.insert!()

    socket = socket(UserSocket, "unauthorized-user", %{})
    {:ok, socket} = UserSocket.connect(%{"token" => "Bearer #{access_token.token}"}, socket)

    assert subscribe_and_join(socket, "projects:#{project.id}", %{}) === {:error, %{reason: "unauthorized"}}
  end
end
