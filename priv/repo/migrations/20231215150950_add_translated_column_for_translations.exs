defmodule Accent.Repo.Migrations.AddTranslatedColumnForTranslations do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:translations) do
      add(:translated, :boolean, null: false, default: false)
    end

    execute("UPDATE translations SET translated = true")
  end
end
