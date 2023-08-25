defmodule Accent.Repo.Migrations.AddTopFileCommentAndHeaderToDocument do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add(:header, :text, default: "")
      add(:top_of_the_file_comment, :text, default: "")
    end
  end
end
