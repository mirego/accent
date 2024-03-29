defmodule Accent.Repo.Migrations.AddValueTypeForTranslations do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:translations) do
      add(:value_type, :string)
    end

    alter table(:operations) do
      add(:value_type, :string)
    end
  end
end
