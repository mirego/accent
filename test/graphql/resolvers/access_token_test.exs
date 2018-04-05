defmodule AccentTest.GraphQL.Resolvers.AccessToken do
  use Accent.RepoCase

  alias Accent.GraphQL.Resolvers.AccessToken, as: Resolver

  alias Accent.{
    Repo,
    Project,
    User,
    Collaborator,
    AccessToken
  }

  test "show project" do
    user = %User{email: "test@example.com", bot: true} |> Repo.insert!()
    project = %Project{name: "My project"} |> Repo.insert!()
    %Collaborator{project_id: project.id, user_id: user.id, role: "bot"} |> Repo.insert!()
    token = %AccessToken{user_id: user.id, token: "foo"} |> Repo.insert!()

    assert Resolver.show_project(project, %{}, %{}) == {:ok, token.token}
  end
end
