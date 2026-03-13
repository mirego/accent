defmodule AccentTest.Hook do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Hook
  alias Accent.Hook.Outbounds.Discord
  alias Accent.Hook.Outbounds.Mock
  alias Accent.Hook.Outbounds.Slack
  alias Accent.Integration
  alias Accent.Project
  alias Accent.User

  setup do
    project = Factory.insert(Project)
    user = Factory.insert(User, fullname: "Test", email: "foo@test.com")
    payload = %{test: "hook"}
    context = %Hook.Context{project_id: project.id, user_id: user.id, event: "event", payload: payload}

    worker_args = %{
      "event" => "event",
      "payload" => %{"test" => "hook"},
      "project_id" => project.id,
      "user_id" => user.id
    }

    {:ok, [context: context, project: project, user: user, worker_args: worker_args]}
  end

  test "supported event", %{context: context, worker_args: worker_args} do
    Hook.outbound(%{context | event: "sync"})

    assert_enqueued(
      worker: Mock,
      args: %{worker_args | "event" => "sync"}
    )
  end

  test "outbound enqueues jobs for supported event", %{context: context, worker_args: worker_args} do
    Hook.outbound(%{context | event: "sync"}, [Mock])

    assert_enqueued(
      worker: Mock,
      args: %{worker_args | "event" => "sync"}
    )
  end

  test "integration_services_for_project returns configured services", %{project: project, user: user} do
    Factory.insert(Integration,
      project_id: project.id,
      user_id: user.id,
      service: "slack",
      events: ["sync"],
      data: %{url: "http://example.com"}
    )

    services = Hook.integration_services_for_project(project.id)
    assert "slack" in services
    refute "discord" in services
  end

  test "integration_services_for_project returns empty when none configured", %{project: project} do
    assert Hook.integration_services_for_project(project.id) == []
  end

  test "outbound skips slack when no integration configured", %{context: context} do
    Hook.outbound(%{context | event: "sync"}, [Slack, Discord])

    refute_enqueued(worker: Slack)
    refute_enqueued(worker: Discord)
  end

  test "outbound includes slack when slack integration exists", %{context: context, project: project, user: user} do
    Factory.insert(Integration,
      project_id: project.id,
      user_id: user.id,
      service: "slack",
      events: ["sync"],
      data: %{url: "http://example.com"}
    )

    Hook.outbound(%{context | event: "sync"}, [Slack, Discord])

    assert_enqueued(worker: Slack)
    refute_enqueued(worker: Discord)
  end
end
