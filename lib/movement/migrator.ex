defmodule Movement.Migrator do
  @moduledoc """
    Route action to the module which will execute it or return
    a value without a function call.

    Module used to execute operation should implement the `Migration` behaviour.

    ## Exemple

      # Given an `up` operation:
      %{action: :correct_conflict}
      # And a function call on Migrator
      Migrator.up(:correct_conflict, operation)

    This will call `Accent.Migrator.Migration.Conflict.call(:correct, operation)` where
    operation is the same operation object passed to `Migrator.up/2`.
  """

  alias Movement.Migration.{Conflict, Rollback, Translation}

  def up(%{action: "noop"}), do: nil
  def up(%{action: "autocorrect"}), do: nil
  def up(operation = %{action: "correct_conflict"}), do: Conflict.call(:correct, operation)
  def up(operation = %{action: "uncorrect_conflict"}), do: Conflict.call(:uncorrect, operation)
  def up(operation = %{action: "conflict_on_proposed"}), do: Conflict.call(:on_proposed, operation)
  def up(operation = %{action: "merge_on_proposed"}), do: Conflict.call(:on_proposed, operation)
  def up(operation = %{action: "merge_on_proposed_force"}), do: Conflict.call(:on_proposed, operation)
  def up(operation = %{action: "merge_on_corrected_force"}), do: Conflict.call(:on_proposed, operation)
  def up(operation = %{action: "conflict_on_slave"}), do: Conflict.call(:on_slave, operation)
  def up(operation = %{action: "conflict_on_corrected"}), do: Conflict.call(:on_corrected, operation)
  def up(operation = %{action: "merge_on_corrected"}), do: Conflict.call(:on_corrected, operation)
  def up(operation = %{action: "remove"}), do: Translation.call(:remove, operation)
  def up(operation = %{action: "update"}), do: Translation.call(:update, operation)
  def up(operation = %{action: "update_proposed"}), do: Translation.call(:update_proposed, operation)
  def up(operation = %{action: "version_new"}), do: Translation.call(:version_new, operation)
  def up(operation = %{action: "new"}), do: Translation.call(:new, operation)
  def up(operation = %{action: "renew"}), do: Translation.call(:renew, operation)
  def up(operation = %{action: "rollback"}), do: Translation.call(:restore, operation)

  def up(operations) when is_list(operations), do: Enum.map(operations, &up/1)

  def down(%{action: "noop"}), do: nil
  def down(%{action: "autocorrect"}), do: nil
  def down(operation = %{action: "new"}), do: Rollback.call(:new, operation)
  def down(operation = %{action: "renew"}), do: Rollback.call(:new, operation)
  def down(operation = %{action: "remove"}), do: Rollback.call(:remove, operation)
  def down(operation = %{action: _}), do: Rollback.call(:restore, operation)

  def down(operations) when is_list(operations), do: Enum.map(operations, &down/1)
end
