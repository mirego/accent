defmodule AccentTest.GraphQL.Resolvers.AccessToken do
  use Accent.RepoCase

  alias Accent.GraphQL.Resolvers.AccessToken, as: Resolver

  alias Accent.{
    AccessToken,
    Collaborator,
    Project,
    Repo,
    User
  }

  test "show project" do
    user = %User{email: "test@example.com", bot: true} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()
    %Collaborator{project_id: project.id, user_id: user.id, role: "bot"} |> Repo.insert!()
    token = %AccessToken{user_id: user.id, token: "foo"} |> Repo.insert!()

    assert Resolver.show_project(project, %{}, %{}) == {:ok, token.token}
  end
end
