defmodule Accent.Repo.Migrations.RemoveCommentIdFromOperations do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:operations) do
      remove(:comment_id)
    end
  end
end
