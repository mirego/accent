defmodule Accent.Repo.Migrations.UpdateTranslationsTextToTextType do
  use Ecto.Migration

  def up do
    alter table(:translations) do
      modify :file_comment, :text
    end

    alter table(:operations) do
      modify :file_comment, :text
    end
  end

  def down do
    alter table(:translations) do
      modify :file_comment, :string
    end

    alter table(:operations) do
      modify :file_comment, :string
    end
  end
end
