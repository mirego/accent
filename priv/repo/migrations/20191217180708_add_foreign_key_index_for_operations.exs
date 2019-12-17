defmodule Accent.Repo.Migrations.AddForeignKeyIndexForOperations do
  use Ecto.Migration
  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    create(index("operations", [:rollbacked_operation_id], concurrently: true))
    create(index("operations", [:batch_operation_id], concurrently: true))
  end
end
