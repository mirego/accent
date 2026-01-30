defmodule Movement.Migration.Rollback do
  @moduledoc false
  @behaviour Movement.Migration

  import Movement.EctoMigrationHelper

  alias Accent.Translation

  def call(:new, operation) do
    [
      update_all(operation, %{rollbacked: true}),
      update_all(operation.translation, %{removed: true}),
      update_all_by_field(Translation, :source_translation_id, operation.translation.id, %{source_translation_id: nil})
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
