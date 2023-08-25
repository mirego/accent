defmodule Accent.Repo.Migrations.AddPluralFormsToLanguages do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:languages) do
      add(:plural_forms, :string)
    end
  end
end
