defmodule Accent.Repo.Migrations.AddSourceTranslationIdToTranslations do
  use Ecto.Migration

  def change do
    alter table(:translations) do
      add(:source_translation_id, references(:translations, type: :uuid))
    end
  end
end
