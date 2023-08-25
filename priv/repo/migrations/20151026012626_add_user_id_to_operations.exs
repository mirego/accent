defmodule Accent.Repo.Migrations.AddUserIdToOperations do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:operations) do
      add(:user_id, references(:users, type: :uuid))
    end
  end
end
