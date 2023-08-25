defmodule Accent.Repo.Migrations.AddMachineTranslatedForOperations do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:operations) do
      add(:machine_translated, :boolean)
    end

    execute("UPDATE operations SET machine_translated = false")

    alter table(:operations) do
      modify(:machine_translated, :boolean, default: false, null: false)
    end
  end
end
