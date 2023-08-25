defmodule Accent.RepoCase do
  @moduledoc false
  use ExUnit.CaseTemplate, async: true

  using do
    quote do
      use Oban.Testing, repo: Accent.Repo

      def to_worker_args(struct) do
        struct
        |> Jason.encode!()
        |> Jason.decode!()
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Accent.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Accent.Repo, {:shared, self()})
    end

    :ok
  end
end
