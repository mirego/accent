defmodule Accent.Repo.Migrations.AddProjectPrompts do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:prompts, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, null: true)
      add(:content, :text, null: false)
      add(:quick_access, :string, null: true)

      add(:project_id, references(:projects, type: :uuid), null: false)
      add(:author_id, references(:users, type: :uuid), null: false)

      timestamps()
    end

    create(index(:prompts, [:project_id]))
  end
end
