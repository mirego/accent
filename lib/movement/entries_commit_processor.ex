defmodule Movement.EntriesCommitProcessor do
  @moduledoc false
  alias Movement.MachineTranslations

  @no_action_keys ~w(noop autocorrect)
  @included_slave_actions ~w(new remove renew merge_on_corrected merge_on_proposed merge_on_proposed_force merge_on_corrected_force)

  @doc """
  For list of translations, new data (like the content of a file upload) and a given function,
  returns the list of operations that will be executed. The operations will be neither persisted nor run.

  The list contains the operations for keys that exists in the current translations list. For the removal of
  keys, use the process_for_remove/3 function.
  """
  @spec process(Movement.Context.t()) :: Movement.Context.t()
  def process(%Movement.Context{entries: entries, assigns: assigns, operations: operations} = context) do
    grouped_translations = group_by_key(assigns[:translations])

    new_operations =
      entries
      |> Enum.map(fn entry ->
        current_translation = fetch_current_translation(grouped_translations, entry.key)

        suggested_translation = %Movement.SuggestedTranslation{
          text: entry.value,
          key: entry.key,
          file_comment: entry.comment,
          file_index: entry.index,
          value_type: entry.value_type,
          plural: entry.plural,
          locked: entry.locked,
          translation_id: current_translation && current_translation.id,
          revision_id: Map.get(assigns[:revision], :id),
          version_id: assigns[:version] && Map.get(assigns[:version], :id),
          placeholders: entry.placeholders
        }

        operation = assigns[:comparer].(current_translation, suggested_translation)

        operation =
          if MachineTranslations.enable_machine_translation?(
               operation,
               entry,
               assigns[:revision],
               assigns[:project],
               assigns[:batch_action]
             ) do
            %{operation | machine_translations_enabled: true}
          else
            operation
          end

        %{operation | options: assigns[:options]}
      end)
      |> filter_for_revision(assigns[:revision])
      |> MachineTranslations.translate(assigns[:project], assigns[:master_revision], assigns[:revision])

    %{context | operations: Enum.concat(operations, new_operations)}
  end

  @doc """
  For list of translations and new data (like the content of a file upload),
  returns the list of operations concerning removed keys from the content that will be exectued.
  """
  @spec process_for_remove(Movement.Context.t()) :: Movement.Context.t()
  def process_for_remove(%Movement.Context{entries: entries, assigns: assigns, operations: operations} = context) do
    grouped_entries = group_by_key(entries)
    grouped_entries_keys = Map.keys(grouped_entries)

    new_operations =
      assigns[:translations]
      |> Enum.filter(&(!&1.removed && &1.key not in grouped_entries_keys))
      |> Enum.map(fn current_translation ->
        suggested_translation = %{current_translation | marked_as_removed: true}

        assigns[:comparer].(suggested_translation, suggested_translation)
      end)

    %{context | operations: Enum.concat(operations, new_operations)}
  end

  defp group_by_key(list), do: Enum.group_by(list, & &1.key)

  defp fetch_current_translation(grouped_translations, key) do
    grouped_translations
    |> Map.get(key)
    |> case do
      [value | _rest] when is_map(value) -> value
      _ -> nil
    end
  end

  defp filter_for_revision(operations, %{master: true}) do
    Enum.filter(
      operations,
      fn operation ->
        operation.action not in @no_action_keys
      end
    )
  end

  defp filter_for_revision(operations, _) do
    Enum.filter(
      operations,
      fn operation ->
        operation.action in @included_slave_actions and operation.action not in @no_action_keys
      end
    )
  end
end
