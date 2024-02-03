defmodule Movement.MachineTranslations do
  @moduledoc false
  alias Accent.MachineTranslations
  alias Accent.Operation

  def enable_machine_translation?(_operation, _entry, %{master: true}, _, _), do: false

  def enable_machine_translation?(operation, entry, _, project, action) do
    MachineTranslations.enabled?(project.machine_translations_config) and
      MachineTranslations.enabled_on_action?(project.machine_translations_config, action) and
      operation.text === entry.value
  end

  def translate(operations, _project, nil, _revision), do: operations

  def translate(operations, project, master_revision, revision) do
    translated_texts =
      operations
      |> Enum.filter(& &1.machine_translations_enabled)
      |> Enum.map(&Operation.to_langue_entry(&1, master_revision.id === &1.revision_id, language_slug(revision)))
      |> MachineTranslations.translate(
        language_slug(master_revision),
        language_slug(revision),
        project.machine_translations_config
      )
      |> case do
        entries when is_list(entries) ->
          Map.new(Enum.map(entries, &{&1.id, &1.value}))

        _ ->
          %{}
      end

    Enum.map(operations, fn operation ->
      with true <- operation.machine_translations_enabled,
           text = Map.get(translated_texts, operation.key),
           true <- text !== operation.text do
        %{operation | text: text, machine_translated: true}
      else
        _ -> operation
      end
    end)
  end

  defp language_slug(revision), do: revision.slug || revision.language.slug
end
