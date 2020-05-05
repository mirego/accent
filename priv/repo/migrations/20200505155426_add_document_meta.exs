defmodule Accent.Repo.Migrations.AddDocumentMeta do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add(:meta, :jsonb)
    end
  end
end
