defmodule AccentTest.Hook do
  use Accent.RepoCase, async: true
  use Oban.Testing, repo: Accent.Repo

  alias Accent.{
    Hook,
    Project,
    Repo,
    User
  }

  setup do
    project = %Project{main_color: "#f00", name: "Test"} |> Repo.insert!()
    user = %User{fullname: "Test", email: "foo@test.com"} |> Repo.insert!()
    payload = %{test: "hook"}
    context = %Hook.Context{project_id: project.id, user_id: user.id, event: "event", payload: payload}

    worker_args = %{
      "event" => "event",
      "payload" => %{"test" => "hook"},
      "project_id" => project.id,
      "user_id" => user.id
    }

    {:ok, [context: context, worker_args: worker_args]}
  end

  test "supported event", %{context: context, worker_args: worker_args} do
    Hook.outbound(%{context | event: "sync"})

    assert_enqueued(
      worker: Hook.Outbounds.Mock,
      args: %{worker_args | "event" => "sync"}
    )
  end

  test "unsupported event", %{context: context, worker_args: worker_args} do
    Hook.outbound(%{context | event: "foobar"})

    refute_enqueued(
      worker: Hook.Outbounds.Mock,
      args: %{worker_args | "event" => "foobar"}
    )
  end
end
