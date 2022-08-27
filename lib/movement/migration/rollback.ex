defmodule Movement.Migration.Rollback do
  @behaviour Movement.Migration

  import Movement.EctoMigrationHelper

  def call(:new, operation) do
    [
      update_all(operation, %{rollbacked: true}),
      update_all(operation.translation, %{removed: true})
    ]
  end

  def call(:remove, operation) do
    [
      update_all(operation, %{rollbacked: true}),
      update_all(operation.translation, %{removed: false})
    ]
  end

  def call(:restore, operation) do
    [
      update_all(operation, %{rollbacked: true}),
      update(operation.translation, Map.from_struct(operation.previous_translation))
    ]
  end
end
