defmodule Accent.Repo.Migrations.RemoveProjectLintEntriesIgnore do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:project_lint_entries) do
      remove(:ignore, :boolean, null: false, default: true)
    end
  end
end
