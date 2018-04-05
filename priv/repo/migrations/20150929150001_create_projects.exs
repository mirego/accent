defmodule Accent.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :language_id, references(:languages, type: :uuid)

      timestamps
    end
  end
end
