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
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()

    {:ok, [user: user, project: project]}
  end

  test "create slack", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, integration} = Resolver.create(project, %{service: "slack", events: ["sync"], data: %{url: "http://google.ca"}}, context)

    assert integration.service == "slack"
    assert integration.data.url == "http://google.ca"
    assert integration.events == ["sync"]

    assert get_in(Repo.all(Integration), [Access.all(), Access.key(:service)]) == ["slack"]
    assert get_in(Repo.all(Integration), [Access.all(), Access.key(:events)]) == [["sync"]]
  end

  test "create discord", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, integration} = Resolver.create(project, %{service: "discord", events: ["sync"], data: %{url: "http://google.ca"}}, context)

    assert integration.service == "discord"
    assert integration.data.url == "http://google.ca"
    assert integration.events == ["sync"]

    assert get_in(Repo.all(Integration), [Access.all(), Access.key(:service)]) == ["discord"]
    assert get_in(Repo.all(Integration), [Access.all(), Access.key(:events)]) == [["sync"]]
  end

  test "create github", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, integration} = Resolver.create(project, %{service: "github", data: %{repository: "root/test", default_ref: "master", token: "1234"}}, context)

    assert integration.service == "github"
    assert integration.data.repository == "root/test"
    assert integration.data.default_ref == "master"
    assert integration.data.token == "1234"

    assert get_in(Repo.all(Integration), [Access.all(), Access.key(:service)]) == ["github"]
  end

  test "create github error", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, integration} = Resolver.create(project, %{service: "github", data: %{repository: "", default_ref: "master", token: "1234"}}, context)

    assert integration.changes.data.errors == [repository: {"can't be blank", [validation: :required]}]

    assert Repo.all(Integration) == []
  end

  test "create slack error", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, integration} = Resolver.create(project, %{service: "slack", data: %{url: ""}}, context)

    assert integration.changes.data.errors == [url: {"can't be blank", [validation: :required]}]

    assert Repo.all(Integration) == []
  end

  test "create discord error", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, integration} = Resolver.create(project, %{service: "discord", data: %{url: ""}}, context)

    assert integration.changes.data.errors == [url: {"can't be blank", [validation: :required]}]

    assert Repo.all(Integration) == []
  end

  test "create unknown service", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, integration} = Resolver.create(project, %{service: "foo", data: %{url: ""}}, context)

    assert integration.errors == [service: {"is invalid", [validation: :inclusion, enum: ["slack", "github", "discord"]]}]

    assert Repo.all(Integration) == []
  end

  test "update", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}
    integration = %Integration{project_id: project.id, user_id: user.id, service: "slack", events: ["sync"], data: %{url: "http://google.ca"}} |> Repo.insert!()

    {:ok, updated_integration} = Resolver.update(integration, %{data: %{url: "http://example.com/update"}}, context)

    assert updated_integration.data.url == "http://example.com/update"
  end

  test "delete", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}
    integration = %Integration{project_id: project.id, user_id: user.id, service: "slack", events: ["sync"], data: %{url: "http://google.ca"}} |> Repo.insert!()

    {:ok, deleted_integration} = Resolver.delete(integration, %{}, context)

    assert deleted_integration.__meta__.state == :deleted
  end
end
