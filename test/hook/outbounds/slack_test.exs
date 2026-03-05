defmodule AccentTest.Hook.Outbounds.Slack do
  @moduledoc false
  use Accent.RepoCase, async: false

  import Mock

  alias Accent.Hook.Outbounds.Slack
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
        service: "slack",
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
        text:
          String.trim_trailing("""
          *Test* just synced a file: _foo.json_

          *Stats:*
          New: _4_
          Conflict on proposed: _10_
          """)
      })

    with_mock(HTTPoison,
      post: fn ^received_url, ^received_body, ^received_headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: ""}}
      end
    ) do
      Slack.perform(%Oban.Job{args: context})
    end

    [execution] = Repo.all(IntegrationExecution)
    assert execution.integration_id === integration.id
    assert execution.user_id === user.id
    assert execution.state === :success
    assert execution.data === %{"event" => "sync", "service" => "slack"}
    assert execution.results["status"] === 200

    updated_integration = Repo.get!(Integration, integration.id)
    assert updated_integration.last_integration_execution_id === execution.id
  end
end
