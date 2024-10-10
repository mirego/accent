defmodule Accent.RepoCase do
  @moduledoc false
  use ExUnit.CaseTemplate, async: true

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      use Oban.Testing, repo: Accent.Repo

      alias Accent.Factory

      def to_worker_args(struct) do
        struct
        |> Jason.encode!()
        |> Jason.decode!()
      end
    end
  end

  setup tags do
    setup_sandbox(tags)

    :ok
  end

  def setup_sandbox(tags) do
    pid = Sandbox.start_owner!(Accent.Repo, shared: not tags[:async])
    on_exit(fn -> Sandbox.stop_owner(pid) end)
  end
end
