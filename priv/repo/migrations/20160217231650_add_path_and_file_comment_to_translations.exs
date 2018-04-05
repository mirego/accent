defmodule Accent.Repo.Migrations.AddPathAndFileCommentToTranslations do
  use Ecto.Migration

  def change do
    alter table(:translations) do
      add :file_path, :string
      add :file_comment, :string
    end
  end
end
