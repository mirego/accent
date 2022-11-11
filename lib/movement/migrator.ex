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

  # Inserts operations by batch of 500 to prevent parameters
  # overflow in database adapter
  @operations_chunk 500

  require Ecto.Query

  alias Accent.Repo
  alias Movement.Migration.{Conflict, Rollback, Translation}

  def down(operations), do: persist(Enum.map(List.wrap(operations), &do_down/1))
  def up(operations), do: persist(Enum.map(List.wrap(operations), &do_up/1))

  defp do_up(%{action: "noop"}), do: []
  defp do_up(%{action: "autocorrect"}), do: []
  defp do_up(operation = %{action: "correct_conflict"}), do: Conflict.call(:correct, operation)
  defp do_up(operation = %{action: "uncorrect_conflict"}), do: Conflict.call(:uncorrect, operation)
  defp do_up(operation = %{action: "conflict_on_proposed"}), do: Conflict.call(:on_proposed, operation)
  defp do_up(operation = %{action: "merge_on_proposed"}), do: Conflict.call(:on_proposed, operation)
  defp do_up(operation = %{action: "merge_on_proposed_force"}), do: Conflict.call(:on_proposed, operation)
  defp do_up(operation = %{action: "merge_on_corrected_force"}), do: Conflict.call(:on_proposed, operation)
  defp do_up(operation = %{action: "conflict_on_slave"}), do: Conflict.call(:on_slave, operation)
  defp do_up(operation = %{action: "conflict_on_corrected"}), do: Conflict.call(:on_corrected, operation)
  defp do_up(operation = %{action: "merge_on_corrected"}), do: Conflict.call(:on_corrected, operation)
  defp do_up(operation = %{action: "remove"}), do: Translation.call(:remove, operation)
  defp do_up(operation = %{action: "update"}), do: Translation.call(:update, operation)
  defp do_up(operation = %{action: "update_proposed"}), do: Translation.call(:update_proposed, operation)
  defp do_up(operation = %{action: "version_new"}), do: Translation.call(:version_new, operation)
  defp do_up(operation = %{action: "new"}), do: Translation.call(:new, operation)
  defp do_up(operation = %{action: "renew"}), do: Translation.call(:renew, operation)
  defp do_up(operation = %{action: "rollback"}), do: Translation.call(:restore, operation)

  defp do_down(%{action: "noop"}), do: []
  defp do_down(%{action: "autocorrect"}), do: []
  defp do_down(operation = %{action: "new"}), do: Rollback.call(:new, operation)
  defp do_down(operation = %{action: "renew"}), do: Rollback.call(:new, operation)
  defp do_down(operation = %{action: "remove"}), do: Rollback.call(:remove, operation)
  defp do_down(operation = %{action: _}), do: Rollback.call(:restore, operation)

  defp persist(operations) do
    operations = List.flatten(operations)
    actions = Enum.group_by(operations, fn {action, _payload} -> action end, &elem(&1, 1))

    results = []
    results = results ++ migrate_insert_all_operations(Map.get(actions, :insert_all, []))
    results = results ++ migrate_update_all_operations(Map.get(actions, :update_all, []))
    results = results ++ migrate_update_all_dynamic_operations(Map.get(actions, :update_all_dynamic, []))
    results = results ++ migrate_insert_operations(Map.get(actions, :insert, []))
    results = results ++ migrate_update_operations(Map.get(actions, :update, []))

    results
  end

  defp migrate_insert_operations(operations) do
    Enum.map(operations, &Repo.insert!/1)
  end

  defp migrate_update_operations(operations) do
    Enum.map(operations, fn {struct, params} ->
      struct
      |> struct.__struct__.changeset(params)
      |> Repo.update!()
    end)
  end

  defp migrate_insert_all_operations(operations) do
    operations
    |> Enum.group_by(fn {schema, _payload} -> schema end, &elem(&1, 1))
    |> Enum.map(fn {schema, records} ->
      records
      |> Enum.chunk_every(@operations_chunk)
      |> Enum.map(&Repo.insert_all(schema, &1, placeholders: %{now: DateTime.utc_now()}))
    end)
  end

  defp migrate_update_all_operations(operations) do
    operations
    |> Enum.group_by(fn {schema, _struct_id, params} -> {schema, params} end, &elem(&1, 1))
    |> Enum.map(fn {{schema, params}, record_ids} ->
      record_ids
      |> Enum.chunk_every(@operations_chunk)
      |> Enum.map(fn ids ->
        query = Ecto.Query.from(entries in schema, where: entries.id in ^ids)
        Repo.update_all(query, set: Map.to_list(params))
      end)
    end)
  end

  defp migrate_update_all_dynamic_operations(operations) do
    operations
    |> Enum.group_by(fn {schema, _struct_id, types, fields, _values} -> {schema, types, fields} end, &{elem(&1, 1), elem(&1, 4)})
    |> Enum.map(fn {{schema, types, fields}, records} ->
      records
      |> Enum.chunk_every(@operations_chunk)
      |> Enum.map(fn records ->
        Movement.Persisters.OperationsUpdateAllDynamic.update({{schema, types, fields}, records})
      end)
    end)
  end
end
