defmodule Accent.Repo.Migrations.AddPlaceholdersForTranslations do
  use Ecto.Migration

  def change do
    alter table(:translations) do
      add(:placeholders, {:array, :string}, null: false, default: [])
    end

    alter table(:operations) do
      add(:placeholders, {:array, :string}, null: false, default: [])
    end
  end
end
