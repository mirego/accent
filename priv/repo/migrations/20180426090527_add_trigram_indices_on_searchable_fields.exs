defmodule Accent.Repo.Migrations.AddTrigramIndicesOnSearchableFields do
  use Ecto.Migration

  require Logger

  @superuser_query "SELECT usesuper FROM pg_user WHERE usename = CURRENT_USER;"

  def change do
    if superuser?() do
      execute("CREATE EXTENSION pg_trgm", "DROP EXTENSION pg_trgm")

      create(index(:languages, ["name gin_trgm_ops"], using: :gin))
      create(index(:projects, ["name gin_trgm_ops"], using: :gin))
      create(index(:translations, ["key gin_trgm_ops"], using: :gin))
      create(index(:translations, ["corrected_text gin_trgm_ops"], using: :gin))
    else
      Logger.warn("""
      Can’t create pg_trgm extension.

      Only superuser can create extensions. If you are not superuser of the database (like on Heroku PostgreSQL), you need to create the extension manually before executing the migration. Without this migration, the search index will be less performant.

      The query used to determine if the process is a superuser: "#{@superuser_query}"
      """)
    end
  end

  defp superuser? do
    results = Ecto.Adapters.SQL.query!(Accent.Repo, @superuser_query, [])
    match?(%{rows: [[true]]}, results)
  end
end
