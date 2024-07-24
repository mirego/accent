defmodule AccentTest.GraphQL.Resolvers.Integration do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.GraphQL.Resolvers.Integration, as: Resolver
  alias Accent.Integration
  alias Accent.Project
  alias Accent.Repo
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

  test "create slack", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, integration} =
      Resolver.create(project, %{service: "slack", events: ["sync"], data: %{url: "http://google.ca"}}, context)

    assert integration.service == "slack"
    assert integration.data.url == "http://google.ca"
    assert integration.events == ["sync"]

    assert get_in(Repo.all(Integration), [Access.all(), Access.key(:service)]) == ["slack"]
    assert get_in(Repo.all(Integration), [Access.all(), Access.key(:events)]) == [["sync"]]
  end

  test "create discord", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, integration} =
      Resolver.create(project, %{service: "discord", events: ["sync"], data: %{url: "http://google.ca"}}, context)

    assert integration.service == "discord"
    assert integration.data.url == "http://google.ca"
    assert integration.events == ["sync"]

    assert get_in(Repo.all(Integration), [Access.all(), Access.key(:service)]) == ["discord"]
    assert get_in(Repo.all(Integration), [Access.all(), Access.key(:events)]) == [["sync"]]
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

    assert integration.errors == [
             service:
               {"is invalid",
                [validation: :inclusion, enum: ["slack", "github", "discord", "azure_storage_container", "aws_s3"]]}
           ]

    assert Repo.all(Integration) == []
  end

  test "update", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    integration =
      Factory.insert(Integration,
        project_id: project.id,
        user_id: user.id,
        service: "slack",
        events: ["sync"],
        data: %{id: Ecto.UUID.generate(), url: "http://google.ca"}
      )

    {:ok, updated_integration} = Resolver.update(integration, %{data: %{url: "http://example.com/update"}}, context)

    assert updated_integration.data.url == "http://example.com/update"
  end

  test "delete", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    integration =
      Factory.insert(Integration,
        project_id: project.id,
        user_id: user.id,
        service: "slack",
        events: ["sync"],
        data: %{id: Ecto.UUID.generate(), url: "http://google.ca"}
      )

    {:ok, deleted_integration} = Resolver.delete(integration, %{}, context)

    assert deleted_integration.__meta__.state == :deleted
  end
end
