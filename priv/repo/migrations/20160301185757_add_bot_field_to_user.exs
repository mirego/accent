defmodule Accent.Repo.Migrations.AddBotFieldToUser do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:bot, :boolean, default: false)
    end
  end
end
