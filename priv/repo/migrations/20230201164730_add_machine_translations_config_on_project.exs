defmodule Accent.Repo.Migrations.AddMachineTranslationsConfigOnProject do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add(:machine_translations_config, :binary)
    end
  end
end
