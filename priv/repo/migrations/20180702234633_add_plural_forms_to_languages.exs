defmodule Accent.Repo.Migrations.AddPluralFormsToLanguages do
  use Ecto.Migration

  def change do
    alter table(:languages) do
      add(:plural_forms, :string)
    end
  end
end
