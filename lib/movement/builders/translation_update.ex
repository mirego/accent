defmodule Movement.Builders.TranslationUpdate do
  @behaviour Movement.Builder

  alias Movement.Mappers.Operation, as: OperationMapper

  @action "update"

  def build(context = %Movement.Context{assigns: %{text: text, translation: %{corrected_text: corrected_text}}}) when text === corrected_text, do: context

  def build(context = %Movement.Context{assigns: %{translation: translation, text: text}, operations: operations}) do
    value_type = parse_value_type(translation, text)
    operation = OperationMapper.map(@action, translation, %{text: text, value_type: value_type})

    %{context | operations: Enum.concat(operations, [operation])}
  end

  defp parse_value_type(_translation, ""), do: "empty"
  defp parse_value_type(%{value_type: "null"}, value) when value != "null", do: "string"
  defp parse_value_type(%{value_type: "empty"}, value) when value != "", do: "string"
  defp parse_value_type(_translation, _value), do: "string"
end
