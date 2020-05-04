defmodule Accent.Repo.Migrations.UniqueCollaboratorEmail do
  use Ecto.Migration

  def change do
    create(unique_index(:collaborators, [:email, :project_id]))
  end
end
