defmodule Accent.Repo.Migrations.AddCopyOnUpdateTranslationOnVersions do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:versions) do
      add(:copy_on_update_translation, :boolean, default: false, null: false)
    end
  end
end
