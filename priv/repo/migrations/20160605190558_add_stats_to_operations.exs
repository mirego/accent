defmodule Accent.Repo.Migrations.AddMetaToOperations do
  use Ecto.Migration

  def change do
    alter table(:operations) do
      add :stats, {:array, :map}, default: []
    end
  end
end
