defmodule Langue.Utils.NestedSerializerHelper do
  alias Langue.Utils.NestedParserHelper

  def map_value({nil, [%{value: value, value_type: type} | _t]}, _index), do: entry_value_to_string(value, type)
  def map_value({key, values}, index) when is_binary(key), do: {key, group_by(values, index + 1)}

  defp group_by(entries, index) do
    entries
    |> NestedParserHelper.group_by_key_with_index(index)
    |> parse_children(index)
  end

  defp parse_children(entries = [{"__KEY__" <> _array_index, _values} | _rest], index) do
    entries
    |> Enum.map(fn {_key, values} -> group_by(values, index + 1) end)
  end

  defp parse_children(entries, index) do
    entries
    |> Enum.map(&map_value(&1, index))
    |> extract_single_value
  end

  defp extract_single_value([null_value | _rest]) when is_nil(null_value), do: null_value
  defp extract_single_value([boolean | _rest]) when is_boolean(boolean), do: boolean
  defp extract_single_value([string | _rest]) when is_binary(string), do: string
  defp extract_single_value([integer | _rest]) when is_integer(integer), do: integer
  defp extract_single_value([float | _rest]) when is_float(float), do: float
  defp extract_single_value(values), do: values

  def entry_value_to_string("true", "boolean"), do: true
  def entry_value_to_string("false", "boolean"), do: false
  def entry_value_to_string("null", "null"), do: nil

  def entry_value_to_string(integer, "integer") do
    case Integer.parse(integer) do
      {parsed, _rest} -> parsed
      :error -> integer
    end
  end

  def entry_value_to_string(float, "float") do
    case Float.parse(float) do
      {parsed, _rest} -> parsed
      :error -> float
    end
  end

  def entry_value_to_string(nil, _type), do: ""
  def entry_value_to_string(string, _type), do: string
end
