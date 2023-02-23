defmodule Accent.Repo.Migrations.AddPgStatStatementExtension do
  use Ecto.Migration

  require Logger

  @superuser_query "SELECT usesuper FROM pg_user WHERE usename = CURRENT_USER;"

  def change do
    if superuser?() do
      execute("CREATE EXTENSION IF NOT EXISTS pg_stat_statements", "DROP EXTENSION IF EXISTS pg_stat_statements")
    else
      Logger.warn("""
      Can’t create pg_stat_statements extension.

      Only superuser can create extensions. If you are not superuser of the database (like on Heroku PostgreSQL), you need to create the extension manually before executing the migration.

      The query used to determine if the process is a superuser: "#{@superuser_query}"
      """)
    end
  end

  defp superuser? do
    results = Ecto.Adapters.SQL.query!(Accent.Repo, @superuser_query, [])
    match?(%{rows: [[true]]}, results)
  end
end
