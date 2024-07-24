defmodule AccentTest.GraphQL.Resolvers.Permission do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.GraphQL.Resolvers.Permission, as: Resolver
  alias Accent.Project
  alias Accent.User

  defmodule PlugConn do
    @moduledoc false
    defstruct [:assigns]
  end

  setup do
    user = Factory.insert(User)
    project = Factory.insert(Project)

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
    assert :show_project in permissions
  end

  test "list project as reviewer", %{user: user, project: project} do
    user = %{user | permissions: %{project.id => "reviewer"}}
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, permissions} = Resolver.list_project(project, %{}, context)

    assert :create_slave not in permissions
  end
end
