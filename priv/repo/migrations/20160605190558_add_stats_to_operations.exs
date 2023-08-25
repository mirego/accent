defmodule Accent.Repo.Migrations.AddMetaToOperations do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:operations) do
      add(:stats, {:array, :map}, default: [])
    end
  end
end
