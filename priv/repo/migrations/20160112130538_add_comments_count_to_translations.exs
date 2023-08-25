defmodule Accent.Repo.Migrations.AddCommentsCountToTranslations do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:translations) do
      add(:comments_count, :integer, default: 0)
    end
  end
end
