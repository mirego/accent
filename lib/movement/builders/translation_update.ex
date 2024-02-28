defmodule Movement.Builders.TranslationUpdate do
  @moduledoc false
  @behaviour Movement.Builder

  alias Accent.Version
  alias Movement.Mappers.Operation, as: OperationMapper

  @action "update"

  def build(
        %Movement.Context{assigns: %{text: text, translation: %{corrected_text: corrected_text, translated: true}}} =
          context
      )
      when text === corrected_text,
      do: context

  def build(%Movement.Context{assigns: %{translation: translation, text: text}, operations: operations} = context) do
    value_type = Movement.Mappers.ValueType.from_translation_new_value(translation, text)
    operation = OperationMapper.map(@action, translation, %{text: text, value_type: value_type})

    copy_version_operation =
      if copy_translation_update_to_latest_version?(translation) do
        copy_translation_update_to_latest_version(translation, text)
      end

    %{context | operations: Enum.concat(operations, [operation] ++ List.wrap(copy_version_operation))}
  end

  defp copy_translation_update_to_latest_version(translation, text) do
    source_translation = Accent.Repo.one!(Ecto.assoc(translation, :source_translation))
    value_type = Movement.Mappers.ValueType.from_translation_new_value(source_translation, text)
    OperationMapper.map(@action, source_translation, %{text: text, value_type: value_type})
  end

  defp copy_translation_update_to_latest_version?(translation) do
    if translation.version_id do
      version = Accent.Repo.get(Version, translation.version_id)

      version.copy_on_update_translation
    end
  end
end
