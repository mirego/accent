defmodule Accent.RepoCase do
  use ExUnit.CaseTemplate, async: true

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Accent.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Accent.Repo, {:shared, self()})
    end

    :ok
  end
end
