defmodule Accent.Repo.Migrations.RenameFromOperationToRollbackedOperationId do
  @moduledoc false
  use Ecto.Migration

  def change do
    rename(table(:operations), :from_operation_id, to: :rollbacked_operation_id)
  end
end
