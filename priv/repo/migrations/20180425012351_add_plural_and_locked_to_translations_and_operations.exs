defmodule Accent.Repo.Migrations.AddPluralAndLockedToTranslationsAndOperations do
  use Ecto.Migration

  def change do
    alter table(:translations) do
      add(:plural, :boolean, default: false, null: false)
      add(:locked, :boolean, default: false, null: false)
    end

    alter table(:operations) do
      add(:plural, :boolean, default: false, null: false)
      add(:locked, :boolean, default: false, null: false)
    end
  end
end
