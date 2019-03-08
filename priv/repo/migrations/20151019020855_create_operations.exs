defmodule Accent.Repo.Migrations.CreateOperations do
  use Ecto.Migration

  def change do
    create table(:operations, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:action, :string)
      add(:key, :text)
      add(:text, :text)
      add(:previous_translation, :json)

      add(:translation_id, references(:translations, type: :uuid))
      add(:revision_id, references(:revisions, type: :uuid))
      add(:project_id, references(:projects, type: :uuid))
      add(:comment_id, references(:comments, type: :uuid))

      add(:batch, :boolean, default: false)

      timestamps()
    end

    alter table(:operations) do
      add(:batch_operation_id, references(:operations, type: :uuid))
      add(:from_operation_id, references(:operations, type: :uuid))
    end
  end
end
