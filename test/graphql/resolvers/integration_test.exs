defmodule AccentTest.GraphQL.Resolvers.Integration do
  use Accent.RepoCase

  alias Accent.GraphQL.Resolvers.Integration, as: Resolver

  alias Accent.{
    Integration,
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
    project = %Project{name: "My project"} |> Repo.insert!()

    {:ok, [user: user, project: project]}
  end

  test "create", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.create(project, %{service: "slack", events: ["sync"], data: %{url: "http://google.ca"}}, context)

    assert get_in(result, [:errors]) == nil
    assert get_in(Repo.all(Integration), [Access.all(), Access.key(:service)]) == ["slack"]
    assert get_in(Repo.all(Integration), [Access.all(), Access.key(:events)]) == [["sync"]]
  end

  test "update", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}
    integration = %Integration{project_id: project.id, user_id: user.id, service: "slack", events: ["sync"], data: %{url: "http://google.ca"}} |> Repo.insert!()

    {:ok, result} = Resolver.update(integration, %{data: %{url: "http://example.com/update"}}, context)

    assert get_in(result, [:errors]) == nil
    assert get_in(result, [:integration, Access.key(:data), Access.key(:url)]) == "http://example.com/update"
  end

  test "delete", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}
    integration = %Integration{project_id: project.id, user_id: user.id, service: "slack", events: ["sync"], data: %{url: "http://google.ca"}} |> Repo.insert!()

    {:ok, result} = Resolver.delete(integration, %{}, context)

    assert get_in(result, [:errors]) == nil
    assert get_in(result, [:integration, Access.key(:__meta__), Access.key(:state)]) == :deleted
  end
end
