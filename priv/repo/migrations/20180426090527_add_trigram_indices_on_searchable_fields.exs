defmodule Accent.Repo.Migrations.AddTrigramIndicesOnSearchableFields do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION pg_trgm", "DROP EXTENSION pg_trgm")

    create(index(:languages, ["name gin_trgm_ops"], using: :gin))
    create(index(:projects, ["name gin_trgm_ops"], using: :gin))
    create(index(:translations, ["key gin_trgm_ops"], using: :gin))
    create(index(:translations, ["corrected_text gin_trgm_ops"], using: :gin))
  end
end
