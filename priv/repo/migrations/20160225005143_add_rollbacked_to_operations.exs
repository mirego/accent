defmodule Accent.Repo.Migrations.AddRollbackedToOperations do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:operations) do
      add(:rollbacked, :boolean, default: false)
    end
  end
end
