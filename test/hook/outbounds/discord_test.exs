defmodule AccentTest.Hook.Outbounds.Discord do
  @moduledoc false
  use Accent.RepoCase, async: false

  import Mock

  alias Accent.Hook.Outbounds.Discord
  alias Accent.Integration
  alias Accent.Project
  alias Accent.User

  setup do
    project = Factory.insert(Project)
    user = Factory.insert(User, fullname: "Test", email: "foo@test.com")

    Factory.insert(Integration,
      project_id: project.id,
      user_id: user.id,
      service: "discord",
      events: ["sync"],
      data: %{url: "http://example.com"}
    )

    [project: project, user: user]
  end

  test "single event with single integration", %{project: project, user: user} do
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

    with_mock(HTTPoison, [post: fn ^received_url, ^received_body, ^received_headers -> {:ok, "done"} end],
      do: Discord.perform(%Oban.Job{args: context})
    )
  end
end
