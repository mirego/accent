defmodule Movement.Migrator do
  @moduledoc """
    Route migration to the module which will execute it or return
    a value without a function call.

    Using a simple DSL with an `up` and `down` function, it creates functions in the same
    fashion as the `Plug` library.

    Module use to execute operation should implement the `Migration` behaviour.

    ## Exemple

      # Given an `up` statement:
      up :correct_conflict, Migration.Conflict, :correct
      # And a function call on Migrator
      Migrator.up(:correct_conflict, operation)

    This will call `Accent.Migrator.Migration.Conflict.call(:correct, operation)` where
    operation is the same operation object passed to `Migrator.up/2`.
  """

  import Movement.Migrator.Macros
  alias Movement.Migration.{Conflict, Translation, Rollback}

  def up(operations) when is_list(operations), do: Enum.map(operations, &up/1)
  def down(operations) when is_list(operations), do: Enum.map(operations, &down/1)

  # Noop
  up(:noop, {:ok, :noop})
  down(:noop, {:ok, :noop})

  # Autocorrect
  up(:autocorrect, {:ok, :autocorrect})
  down(:autocorrect, {:ok, :autocorrect})

  # Conflicts
  up(:correct_conflict, Conflict, :correct)
  up(:uncorrect_conflict, Conflict, :uncorrect)
  up(:conflict_on_proposed, Conflict, :on_proposed)
  up(:merge_on_proposed, Conflict, :on_proposed)
  up(:merge_on_proposed_force, Conflict, :on_proposed)
  up(:conflict_on_slave, Conflict, :on_slave)
  up(:conflict_on_corrected, Conflict, :on_corrected)
  up(:merge_on_corrected, Conflict, :on_corrected)
  up(:merge_on_corrected_force, Conflict, :on_proposed)

  # Translations
  up(:remove, Translation, :remove)
  up(:update, Translation, :update)
  up(:update_proposed, Translation, :update_proposed)
  up(:version_new, Translation, :version_new)
  up(:new, Translation, :new)
  up(:renew, Translation, :renew)

  # Rollback
  up(:rollback, Rollback, :restore)

  down(:new, Rollback, :new)
  down(:renew, Rollback, :new)
  down(:remove, Rollback, :remove)

  down(:update, Rollback, :restore)
  down(:update_proposed, Rollback, :restore)
  down(:conflict_on_slave, Rollback, :restore)
  down(:conflict_on_proposed, Rollback, :restore)
  down(:conflict_on_corrected, Rollback, :restore)
  down(:merge_on_proposed_force, Rollback, :restore)
  down(:merge_on_proposed, Rollback, :restore)
  down(:merge_on_corrected, Rollback, :restore)
  down(:correct_conflict, Rollback, :restore)
  down(:uncorrect_conflict, Rollback, :restore)

  down(:rollback, Rollback, :rollback)
end
