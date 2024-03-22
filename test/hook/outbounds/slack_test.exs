defmodule MockHttpClient do
  @moduledoc false
  def post(url, body, header) do
    send(self(), {:post, %{url: url, body: body, header: header}})
  end
end

defmodule AccentTest.Hook.Outbounds.Slack do
  @moduledoc false
  use Accent.RepoCase, async: false

  import Mock

  alias Accent.Hook.Outbounds.Slack
  alias Accent.Integration
  alias Accent.Project
  alias Accent.Repo
  alias Accent.User

  setup do
    project = Factory.insert(Project, main_color: "#f00", name: "Test")
    user = Factory.insert(User, fullname: "Test", email: "foo@test.com")

    Repo.insert!(%Integration{
      project: project,
      user: user,
      service: "slack",
      events: ["sync"],
      data: %{url: "http://example.com"}
    })

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
        text:
          String.trim_trailing("""
          *Test* just synced a file: _foo.json_

          *Stats:*
          New: _4_
          Conflict on proposed: _10_
          """)
      })

    with_mock(HTTPoison, [post: fn ^received_url, ^received_body, ^received_headers -> {:ok, "done"} end],
      do: Slack.perform(%Oban.Job{args: context})
    )
  end
end
