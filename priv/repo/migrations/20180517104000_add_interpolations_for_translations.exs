defmodule Accent.Repo.Migrations.AddInterpolationsForTranslations do
  use Ecto.Migration

  def change do
    alter table(:translations) do
      add(:interpolations, {:array, :string}, null: false, default: [])
    end

    alter table(:operations) do
      add(:interpolations, {:array, :string}, null: false, default: [])
    end
  end
end
