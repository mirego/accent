defmodule Langue.Utils.NestedParserHelper do
  alias Langue.Entry

  @nested_separator "."
  @plural_suffixes ~w(.zero .one .two .few .many .other)

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
    |> Enum.map(&parse_plural/1)
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
    %Entry{key: key, value: to_string(value), value_type: Langue.ValueType.parse(value), comment: ""}
  end
end
