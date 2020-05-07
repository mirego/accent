defmodule Langue.Formatter.ARB.Serializer do
  @behaviour Langue.Formatter.Serializer

  alias Langue.Formatter.Json.Serializer, as: JsonSerializer
  alias Langue.Utils.NestedSerializerHelper

  def serialize(%{entries: entries, document: document}) do
    render =
      entries
      |> Enum.reduce(%{}, fn entry, acc ->
        Map.put(acc, entry.key, NestedSerializerHelper.entry_value_to_string(entry.value, entry.value_type))
      end)
      |> combine_entries_with_meta(document.meta)
      |> JsonSerializer.encode_json()
      |> Kernel.<>("\n")

    %Langue.Formatter.SerializerResult{render: render}
  end

  def combine_entries_with_meta(entries, meta) when meta == %{}, do: entries
  def combine_entries_with_meta(entries, meta), do: parse_meta(entries, meta)

  def parse_meta(_entries, meta) when meta == %{}, do: meta

  def parse_meta(entries, meta) when is_map(meta) do
    Enum.map(meta, fn {key, values} ->
      case Map.get(entries, key) do
        nil ->
          {key, Map.put(values, "value", parse_meta(entries, Map.get(values, "value")))}

        entry_value ->
          {key, Map.put(values, "value", entry_value)}
      end
    end)
    |> Enum.sort(&(index(&1) < index(&2)))
    |> Enum.map(fn {key, %{"value" => value}} ->
      {key, value}
    end)
  end

  def parse_meta(_entries, meta) when is_binary(meta), do: meta

  def index({_key, %{"index" => index}}), do: index
end
