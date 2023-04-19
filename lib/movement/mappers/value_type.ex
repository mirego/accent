defmodule Movement.Mappers.ValueType do
  def from_translation_new_value(_translation, ""), do: "empty"
  def from_translation_new_value(%{value_type: "null"}, value) when value != "null", do: "string"
  def from_translation_new_value(%{value_type: "empty"}, value) when value != "", do: "string"
  def from_translation_new_value(%{value_type: "html"}, _value), do: "html"
  def from_translation_new_value(%{value_type: "boolean"}, "false"), do: "boolean"
  def from_translation_new_value(%{value_type: "boolean"}, "true"), do: "boolean"
  def from_translation_new_value(_translation, _value), do: "string"
end
