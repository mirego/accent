defmodule Accent.Repo.Migrations.AddTrigramIndicesOnSearchableFields do
  use Ecto.Migration

  def change do
    # Only superuser can create extensions. If you are not superuser of the database, you need to create the
    # extension manually before executing the migration.
    if superuser?(), do: execute("CREATE EXTENSION pg_trgm", "DROP EXTENSION pg_trgm")

    create(index(:languages, ["name gin_trgm_ops"], using: :gin))
    create(index(:projects, ["name gin_trgm_ops"], using: :gin))
    create(index(:translations, ["key gin_trgm_ops"], using: :gin))
    create(index(:translations, ["corrected_text gin_trgm_ops"], using: :gin))
  end

  defp superuser? do
    results = Ecto.Adapters.SQL.query!(Accent.Repo, "SELECT usesuper FROM pg_user WHERE usename = CURRENT_USER;", [])
    match?(%{rows: [[true]]}, results)
  end
end
