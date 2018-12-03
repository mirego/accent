defmodule Accent.ReleaseTasks do
  def migrate do
   {:ok, _} = Application.ensure_all_started(:accent)
    path = Application.app_dir(:accent, "priv/repo/migrations")
    Ecto.Migrator.run(Accent.Repo, path, :up, all: true)
  end
end
