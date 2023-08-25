defmodule Accent.Repo.Migrations.AddUniqueConstraintRevisionsLanguageProject do
  @moduledoc false
  use Ecto.Migration

  def change do
    create(index(:revisions, [:project_id, :language_id], unique: true))
  end
end
