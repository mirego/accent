defmodule Accent.Repo.Migrations.RemoveCommentIdFromOperations do
  use Ecto.Migration

  def change do
    alter table(:operations) do
      remove(:comment_id)
    end
  end
end
