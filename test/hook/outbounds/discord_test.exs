defmodule AccentTest.Hook.Outbounds.Discord do
  @moduledoc false
  use Accent.RepoCase, async: false

  import Mock

  alias Accent.Hook.Outbounds.Discord
  alias Accent.Integration
  alias Accent.IntegrationExecution
  alias Accent.Project
  alias Accent.Repo
  alias Accent.User

  setup do
    project = Factory.insert(Project)
    user = Factory.insert(User, fullname: "Test", email: "foo@test.com")

    integration =
      Factory.insert(Integration,
        project_id: project.id,
        user_id: user.id,
        service: "discord",
        events: ["sync"],
        data: %{url: "http://example.com"}
      )

    [project: project, user: user, integration: integration]
  end

  test "single event with single integration", %{project: project, user: user, integration: integration} do
    payload = %{
      document_path: "foo.json",
      batch_operation_stats: [%{action: "new", count: 4}, %{action: "conflict_on_proposed", count: 10}]
    }

    context =
      to_worker_args(%Accent.Hook.Context{project_id: project.id, user_id: user.id, event: "sync", payload: payload})

    received_headers = [{"Content-Type", "application/json"}]
    received_url = "http://example.com"

    received_body =
      Jason.encode!(%{
        content:
          String.trim_trailing("""
          **Test** just synced a file: *foo.json*

          **Stats:**
          New: *4*
          Conflict on proposed: *10*
          """)
      })

    with_mock(HTTPoison,
      post: fn ^received_url, ^received_body, ^received_headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: ""}}
      end
    ) do
      Discord.perform(%Oban.Job{args: context})
    end

    [execution] = Repo.all(IntegrationExecution)
    assert execution.integration_id === integration.id
    assert execution.user_id === user.id
    assert execution.state === :success
    assert execution.data === %{"event" => "sync", "service" => "discord"}
    assert execution.results["status"] === 200

    updated_integration = Repo.get!(Integration, integration.id)
    assert updated_integration.last_executed_at
    assert updated_integration.last_executed_by_user_id === user.id
  end
end
