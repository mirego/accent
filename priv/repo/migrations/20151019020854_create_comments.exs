defmodule Accent.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :text, :text

      add :translation_id, references(:translations, type: :uuid)

      timestamps
    end
  end
end
