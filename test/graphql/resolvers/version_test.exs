defmodule AccentTest.GraphQL.Resolvers.Version do
  use Accent.RepoCase

  alias Accent.GraphQL.Resolvers.Version, as: Resolver

  alias Accent.{
    Project,
    Repo,
    User,
    Version
  }

  defmodule PlugConn do
    defstruct [:assigns]
  end

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()

    version = %Version{name: "version1", tag: "v1", project_id: project.id, user_id: user.id} |> Repo.insert!()

    {:ok, [user: user, project: project, version: version]}
  end

  test "create", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.create(project, %{name: "foo", tag: "f"}, context)

    assert get_in(result, [:version, Access.key(:name)]) == "foo"
    assert get_in(result, [:version, Access.key(:tag)]) == "f"
    assert get_in(result, [:errors]) == nil
  end

  test "create with error", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.create(project, %{name: "foo", tag: nil}, context)

    assert get_in(result, [:version]) == nil
    assert get_in(result, [:errors]) == ["unprocessable_entity"]
  end

  test "update", %{version: version, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.update(version, %{name: "bar", tag: "b"}, context)

    assert get_in(result, [:version, Access.key(:id)]) == version.id
    assert get_in(result, [:version, Access.key(:name)]) == "bar"
    assert get_in(result, [:version, Access.key(:tag)]) == "b"
    assert get_in(result, [:errors]) == nil
  end

  test "list project", %{project: project, version: version} do
    {:ok, result} = Resolver.list_project(project, %{}, %{})

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [version.id]
  end
end
