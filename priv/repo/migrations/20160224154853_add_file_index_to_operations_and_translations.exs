defmodule Accent.Repo.Migrations.AddFileIndexToOperationsAndTranslations do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:operations) do
      add(:file_index, :integer)
    end

    alter table(:translations) do
      add(:file_index, :integer)
    end
  end
end
