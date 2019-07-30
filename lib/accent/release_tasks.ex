defmodule Accent.ReleaseTasks do
  @app :accent

  alias Ecto.Migrator

  def migrate do
    IO.puts("Running migrations for #{@app}…")

    for repo <- repos() do
      {:ok, _, _} = Migrator.with_repo(repo, &Migrator.run(&1, :up, all: true))
    end
  end

  def seed do
    IO.puts("Running seed script for #{@app}…")

    for repo <- repos() do
      Migrator.with_repo(repo, &Accent.Seeds.run(&1))
    end
  end

  def rollback(repo, version) do
    {:ok, _, _} = Migrator.with_repo(repo, &Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
