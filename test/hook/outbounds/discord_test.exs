defmodule AccentTest.Hook.Outbounds.Discord do
  use Accent.RepoCase

  import Mock

  alias Accent.{
    Hook.Outbounds.Discord,
    Integration,
    Project,
    Repo,
    User
  }

  setup do
    project = %Project{main_color: "#f00", name: "Test"} |> Repo.insert!()
    user = %User{fullname: "Test", email: "foo@test.com"} |> Repo.insert!()

    %Integration{
      project: project,
      user: user,
      service: "discord",
      events: ["sync"],
      data: %{url: "http://example.com"}
    }
    |> Repo.insert!()

    [project: project, user: user]
  end

  test "single event with single integration", %{project: project, user: user} do
    payload = %{document_path: "foo.json", batch_operation_stats: [%{action: "new", count: 4}, %{action: "conflict_on_proposed", count: 10}]}
    context = to_worker_args(%Accent.Hook.Context{project_id: project.id, user_id: user.id, event: "sync", payload: payload})
    received_headers = [{"Content-Type", "application/json"}]
    received_url = "http://example.com"

    received_body =
      Jason.encode!(%{
        text: """
        **Test** just synced a file: *foo.json*

        **Stats:**
        new: *4*
        conflict_on_proposed: *10*
        """
      })

    with_mock(HTTPoison, [post: fn ^received_url, ^received_body, ^received_headers -> {:ok, "done"} end], do: Discord.perform(context, %{}))
  end
end
