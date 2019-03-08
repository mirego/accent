defmodule Accent.ReleaseTasks do
  @start_apps ~w(crypto ssl postgrex ecto_sql)a

  def migrate do
    start_services()
    run_migrations()
    run_seeds()
    stop_services()
  end

  defp repos, do: Application.get_env(:accent, :ecto_repos, [])

  defp start_services do
    IO.puts("Starting dependencies…")
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    IO.puts("Starting repos…")
    Enum.each(repos(), & &1.start_link(pool_size: 2))
  end

  defp run_seeds do
    Enum.each(repos(), &run_seeds_for/1)
  end

  defp run_seeds_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
    seed_script = priv_path_for(app, repo, "seeds.exs")

    if File.exists?(seed_script) do
      IO.puts("Running seed script for #{app}")
      Code.eval_file(seed_script)
    end
  end

  defp run_migrations do
    Enum.each(repos(), &run_migrations_for/1)
  end

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
    migrations_path = priv_path_for(app, repo, "migrations")

    IO.puts("Running migrations for #{app}")
    Ecto.Migrator.run(repo, migrations_path, :up, all: true)
  end

  defp priv_path_for(app, repo, filename) do
    priv_dir = "#{:code.priv_dir(app)}"

    repo_underscore =
      repo
      |> Module.split()
      |> List.last()
      |> Macro.underscore()

    Path.join([priv_dir, repo_underscore, filename])
  end

  defp stop_services do
    IO.puts("Success!")
    :init.stop()
  end
end
