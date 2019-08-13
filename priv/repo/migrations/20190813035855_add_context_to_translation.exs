defmodule Accent.Repo.Migrations.AddContextToTranslation do
  use Ecto.Migration

  def change do
    alter table(:translations) do
      add(:message_context, :text)
    end

    alter table(:operations) do
      add(:message_context, :text)
    end
  end
end
