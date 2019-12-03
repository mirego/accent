defmodule Accent.Repo.Migrations.AddLogoToProject do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add(:logo, :text)
    end
  end
end
