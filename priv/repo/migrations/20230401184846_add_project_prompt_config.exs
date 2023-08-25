defmodule Accent.Repo.Migrations.AddProjectPromptConfig do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add(:prompt_config, :binary)
    end
  end
end
