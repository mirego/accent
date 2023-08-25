defmodule Accent.Repo.Migrations.CreateCollaborators do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:collaborators, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:email, :string)
      add(:role, :string)

      add(:user_id, references(:users, type: :uuid))
      add(:project_id, references(:projects, type: :uuid))
      add(:assigner_id, references(:users, type: :uuid))

      timestamps()
    end

    create(index(:collaborators, [:email]))
    create(index(:collaborators, [:user_id, :project_id]))
  end
end
