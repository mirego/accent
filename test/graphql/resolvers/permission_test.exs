defmodule AccentTest.GraphQL.Resolvers.Permission do
  use Accent.RepoCase

  alias Accent.GraphQL.Resolvers.Permission, as: Resolver

  alias Accent.{
    Project,
    Repo,
    User
  }

  defmodule PlugConn do
    defstruct [:assigns]
  end

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()

    {:ok, [user: user, project: project]}
  end

  test "list viewer", %{user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, permissions} = Resolver.list_viewer(user, %{}, context)

    assert :index_permissions in permissions
    assert :index_projects in permissions
    assert :create_project in permissions
  end

  test "list project as owner", %{user: user, project: project} do
    user = %{user | permissions: %{project.id => "owner"}}
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, permissions} = Resolver.list_project(project, %{}, context)

    assert :create_slave in permissions
    assert :show_project_access_token in permissions
    assert :show_project in permissions
  end

  test "list project as reviewer", %{user: user, project: project} do
    user = %{user | permissions: %{project.id => "reviewer"}}
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, permissions} = Resolver.list_project(project, %{}, context)

    assert :create_slave not in permissions
  end
end
