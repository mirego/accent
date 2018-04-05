defmodule Movement.Migration.Rollback do
  @behaviour Movement.Migration

  import Movement.EctoMigrationHelper

  alias Accent.PreviousTranslation

  def call(:new, operation) do
    update(operation, %{rollbacked: true})
    update(operation.translation, %{removed: true})
  end

  def call(:remove, operation) do
    update(operation, %{rollbacked: true})
    update(operation.translation, %{removed: false})
  end

  def call(:restore, operation) do
    update(operation, %{rollbacked: true})
    update(operation.translation, PreviousTranslation.to_translation(operation.previous_translation))
  end

  def call(:rollback, operation) do
    update(operation, %{rollbacked: false})
    update(operation.translation, PreviousTranslation.to_translation(operation.previous_translation))
  end
end
