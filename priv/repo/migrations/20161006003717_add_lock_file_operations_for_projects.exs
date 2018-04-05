defmodule Accent.Repo.Migrations.AddLockFileOperationsForProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :locked_file_operations, :boolean, default: false
    end
  end
end
