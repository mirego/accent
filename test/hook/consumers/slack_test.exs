defmodule MockHttpClient do
  def post(url, body, header) do
    send(:slack_consumer, {:post, %{url: url, body: body, header: header}})
  end
end

defmodule AccentTest.Hook.Consumers.Slack do
  use Accent.RepoCase

  alias Accent.{
    Repo,
    Project,
    User,
    Integration,
    Hook.Consumers.Slack
  }

  setup do
    Process.register(self(), :slack_consumer)

    project = %Project{name: "Test"} |> Repo.insert!()
    user = %User{fullname: "Test", email: "foo@test.com"} |> Repo.insert!()

    %Integration{
      project: project,
      user: user,
      service: "slack",
      events: ["sync"],
      data: %{url: "http://example.com"}
    }
    |> Repo.insert!()

    [project: project, user: user]
  end

  test "single event with single integration", %{project: project, user: user} do
    payload = %{document_path: "foo.json", batch_operation_stats: [%{action: "new", count: 4}, %{action: "conflict_on_proposed", count: 10}]}
    event = %Accent.Hook.Context{project: project, user: user, event: "sync", payload: payload}
    events = [event]

    Slack.handle_events(events, nil, {:http_client, MockHttpClient})

    post_body = """
    *Test* just synced a file: _foo.json_

    *Stats:*
    new: _4_
    conflict_on_proposed: _10_

    """

    post_message = %{body: Poison.encode!(%{text: post_body}), header: [{"Content-Type", "application/json"}], url: "http://example.com"}
    assert_receive {:post, ^post_message}
  end

  test "unknown event", %{project: project, user: user} do
    payload = %{document_path: "foo.json", batch_operation_stats: [%{action: "new", count: 4}]}
    event = %Accent.Hook.Context{project: project, user: user, event: "merge", payload: payload}
    events = [event]

    Slack.handle_events(events, nil, {:http_client, MockHttpClient})

    refute_received {:post, []}
  end
end
