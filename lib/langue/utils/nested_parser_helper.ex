defmodule Langue.Utils.NestedParserHelper do
  @moduledoc false
  alias Langue.Entry

  @nested_separator "."
  @plural_suffixes ~w(.zero .one .two .few .many .other)

  def group_by_key_with_index(entries, index, nested_separator \\ @nested_separator) do
    grouped_entries = Enum.group_by(entries, &key_at(&1, nested_separator, index))

    entries
    |> Enum.reduce(%{keys: MapSet.new(), results: []}, fn entry, acc ->
      key = key_at(entry, nested_separator, index)

      if MapSet.member?(acc.keys, key) do
        acc
      else
        key_entries = Enum.sort_by(grouped_entries[key], &String.ends_with?(&1.key, "_"), :desc)

        acc
        |> Map.put(:results, [{key, key_entries} | acc.results])
        |> Map.put(:keys, MapSet.put(acc.keys, key))
      end
    end)
    |> Map.get(:results)
    |> Enum.reverse()
  end

  def parse(data) do
    data
    |> Enum.map(&flattenize_tuple(&1))
    |> List.flatten()
    |> Enum.with_index(1)
    |> Enum.map(fn {entry, index} -> %{entry | index: index} end)
    |> Enum.map(&parse_plural/1)
  end

  defp key_at(entry, nested_separator, index) do
    entry.key
    |> String.split(nested_separator)
    |> Enum.at(index)
  end

  defp parse_plural(entry) do
    if Enum.any?(@plural_suffixes, &String.ends_with?(entry.key, &1)) do
      %{entry | plural: true}
    else
      entry
    end
  end

  defp flattenize_array({key, value, index}), do: flattenize_tuple({"#{key}#{@nested_separator}__KEY__#{index}", value})

  defp flattenize_tuple({key, value}) when is_tuple(value), do: flattenize_tuple({key, elem(value, 0)})

  defp flattenize_tuple({key, value}) when is_list(value) do
    value
    |> Enum.with_index()
    |> Enum.map(fn {item, index} ->
      if is_tuple(item) && !is_list(elem(item, 0)) do
        flattenize_tuple({"#{key}#{@nested_separator}#{elem(item, 0)}", elem(item, 1)})
      else
        flattenize_array({key, item, index})
      end
    end)
  end

  defp flattenize_tuple({key, value}) do
    %Entry{key: key, value: to_string(value), value_type: Langue.ValueType.parse(value), placeholders: []}
  end
end
