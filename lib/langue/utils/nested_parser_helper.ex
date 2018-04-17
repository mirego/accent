defmodule Langue.Utils.NestedParserHelper do
  alias Langue.Entry

  @nested_separator "."

  def group_by_key_with_index(entries, index, nested_separator \\ @nested_separator) do
    grouped_entries =
      entries
      |> Enum.group_by(fn entry ->
        entry.key |> String.split(nested_separator) |> Enum.at(index)
      end)

    entries
    |> Enum.reduce(%{keys: MapSet.new(), results: []}, fn entry, acc ->
      key = entry.key |> String.split(nested_separator) |> Enum.at(index)

      if MapSet.member?(acc.keys, key) do
        acc
      else
        key_entries = grouped_entries[key]

        acc
        |> Map.put(:results, List.insert_at(acc.results, -1, {key, key_entries}))
        |> Map.put(:keys, MapSet.put(acc.keys, key))
      end
    end)
    |> Map.get(:results)
  end

  def parse(data) do
    data
    |> Enum.map(&flattenize_tuple(&1))
    |> List.flatten()
    |> Enum.with_index(1)
    |> Enum.map(fn {entry, index} -> %{entry | index: index} end)
  end

  defp flattenize_array({key, value, index}), do: flattenize_tuple({"#{key}#{@nested_separator}__KEY__#{index}", value, "string"})

  defp flattenize_tuple({key, value}), do: flattenize_tuple({key, value, "string"})
  defp flattenize_tuple({key, value, type}) when is_tuple(value), do: flattenize_tuple({key, elem(value, 0), type})

  defp flattenize_tuple({key, value, _type}) when is_boolean(value) or value == "false" or value == "true" do
    %Entry{key: key, value: entry_value_to_string(value), value_type: "boolean", comment: ""}
  end

  defp flattenize_tuple({key, value, _type}) when value == "" do
    %Entry{key: key, value: entry_value_to_string(value), value_type: "empty", comment: ""}
  end

  defp flattenize_tuple({key, value, _type}) when value == :null or value == "nil" do
    %Entry{key: key, value: entry_value_to_string(value), value_type: "null", comment: ""}
  end

  defp flattenize_tuple({key, value, _type}) when is_integer(value) do
    %Entry{key: key, value: entry_value_to_string(to_string(value)), value_type: "integer", comment: ""}
  end

  defp flattenize_tuple({key, value, ""}), do: flattenize_tuple({key, value, nil})

  defp flattenize_tuple({key, value, type}) when is_binary(value) do
    %Entry{key: key, value: entry_value_to_string(value), value_type: type, comment: ""}
  end

  defp flattenize_tuple({key, value, type}) when is_list(value) do
    value
    |> Enum.with_index()
    |> Enum.map(fn {item, index} ->
      if is_tuple(item) && !is_list(elem(item, 0)) do
        flattenize_tuple({"#{key}#{@nested_separator}#{elem(item, 0)}", elem(item, 1), type})
      else
        flattenize_array({key, item, index})
      end
    end)
  end

  defp entry_value_to_string(true), do: "true"
  defp entry_value_to_string(false), do: "false"
  defp entry_value_to_string(:null), do: "null"
  defp entry_value_to_string(value), do: value
end
