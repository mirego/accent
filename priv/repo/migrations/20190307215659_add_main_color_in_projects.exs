defmodule Accent.Repo.Migrations.AddMainColorInProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add(:main_color, :string)
    end

    execute("UPDATE projects SET main_color = '#28cb87'")

    alter table(:projects) do
      modify(:main_color, :string, null: false)
    end
  end
end
