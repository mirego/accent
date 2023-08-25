defmodule AccentTest.GraphQL.Resolvers.Collaborator do
  @moduledoc false
  use Accent.RepoCase
  use Oban.Testing, repo: Accent.Repo

  alias Accent.Collaborator
  alias Accent.GraphQL.Resolvers.Collaborator, as: Resolver
  alias Accent.Project
  alias Accent.Repo
  alias Accent.User

  defmodule PlugConn do
    @moduledoc false
    defstruct [:assigns]
  end

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    project = Repo.insert!(%Project{main_color: "#f00", name: "My project"})

    {:ok, [user: user, project: project]}
  end

  test "create", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.create(project, %{email: "test@example.com", role: "admin"}, context)

    assert_enqueued(
      worker: Accent.Hook.Outbounds.Mock,
      args: %{
        "event" => "create_collaborator",
        "payload" => %{"collaborator" => %{"email" => "test@example.com"}},
        "project_id" => project.id,
        "user_id" => user.id
      }
    )

    assert get_in(result, [:errors]) == nil
    assert get_in(Repo.all(Collaborator), [Access.all(), Access.key(:email)]) == ["test@example.com"]
    assert get_in(Repo.all(Collaborator), [Access.all(), Access.key(:role)]) == ["admin"]
  end

  test "update", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}
    collaborator = Repo.insert!(%Collaborator{email: "test@example.com", role: "reviewer", project_id: project.id})

    {:ok, result} = Resolver.update(collaborator, %{role: "owner"}, context)

    assert get_in(result, [:errors]) == nil
    assert get_in(result, [:collaborator, Access.key(:role)]) == "owner"
  end

  test "delete", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}
    collaborator = Repo.insert!(%Collaborator{email: "test@example.com", role: "reviewer", project_id: project.id})

    {:ok, result} = Resolver.delete(collaborator, %{}, context)

    assert get_in(result, [:errors]) == nil
    assert get_in(result, [:collaborator]) == collaborator
  end
end
