defmodule Accent.Repo.Migrations.AddPathAndFileCommentToOperations do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:operations) do
      add(:file_path, :string)
      add(:file_comment, :string)
    end
  end
end
