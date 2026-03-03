defmodule AccentTest.GraphQL.Resolvers.IntegrationExecution do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.GraphQL.Resolvers.IntegrationExecution, as: Resolver
  alias Accent.Integration
  alias Accent.IntegrationExecution
  alias Accent.Project
  alias Accent.User
  alias Accent.Version

  setup do
    user = Factory.insert(User)
    project = Factory.insert(Project)

    integration =
      Factory.insert(Integration,
        project_id: project.id,
        user_id: user.id,
        service: "azure_storage_container",
        data: %{azure_storage_container_sas: "http://azure.blob.test/container?sas=1234"}
      )

    {:ok, [user: user, project: project, integration: integration]}
  end

  test "list executions", %{integration: integration, user: user} do
    execution =
      Factory.insert(IntegrationExecution,
        integration_id: integration.id,
        user_id: user.id,
        state: :success,
        data: %{"target_version" => "latest"},
        results: %{"version_tag" => "latest"}
      )

    {:ok, result} = Resolver.list_integration(integration, %{page: 1}, nil)

    assert length(result.entries) === 1
    assert hd(result.entries).id === execution.id
  end

  test "list executions empty", %{integration: integration} do
    {:ok, result} = Resolver.list_integration(integration, %{page: 1}, nil)

    assert result.entries === []
    assert result.meta.total_entries === 0
  end

  test "last by version returns one per integration", %{integration: integration, user: user, project: project} do
    version = Factory.insert(Version, project_id: project.id, name: "v1", tag: "v1", user_id: user.id)

    Factory.insert(IntegrationExecution,
      integration_id: integration.id,
      user_id: user.id,
      version_id: version.id,
      state: :success,
      data: %{"target_version" => "specific", "tag" => "v1"},
      results: %{}
    )

    Factory.insert(IntegrationExecution,
      integration_id: integration.id,
      user_id: user.id,
      version_id: version.id,
      state: :success,
      data: %{"target_version" => "specific", "tag" => "v1"},
      results: %{"version_tag" => "v1"}
    )

    result = Resolver.batch_last_by_version(nil, [version.id])
    executions = Map.get(result, version.id, [])

    assert length(executions) === 1
    assert hd(executions).integration_id === integration.id
  end
end
