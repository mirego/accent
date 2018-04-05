defmodule Accent.Repo.Migrations.CreateTranslations do
  use Ecto.Migration

  def change do
    create table(:translations, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :key, :text
      add :proposed_text, :text
      add :corrected_text, :text
      add :conflicted_text, :text
      add :conflicted, :boolean, [default: false]
      add :removed, :boolean, [default: false]

      add :revision_id, references(:revisions, type: :uuid)

      timestamps
    end

    create index(:translations, [:key])
    create index(:translations, [:revision_id, :conflicted])
    create index(:translations, [:revision_id, :removed])
  end
end
