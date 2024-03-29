defmodule Accent.Repo.Migrations.AddUserIdToComments do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add(:user_id, references(:users, type: :uuid))
    end
  end
end
