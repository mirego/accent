defmodule AccentTest.Hook do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Hook
  alias Accent.Project
  alias Accent.Repo
  alias Accent.User

  setup do
    project = Repo.insert!(%Project{main_color: "#f00", name: "Test"})
    user = Repo.insert!(%User{fullname: "Test", email: "foo@test.com"})
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
end
