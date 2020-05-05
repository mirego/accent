defmodule Langue.Formatter.ARB.Serializer do
  @behaviour Langue.Formatter.Serializer

  alias Langue.Formatter.Json.Serializer, as: JsonSerializer
  alias Langue.Utils.NestedSerializerHelper

  def serialize(%{entries: entries, document: document}) do
    render =
      entries
      |> Enum.map(fn entry ->
        {entry.key, NestedSerializerHelper.entry_value_to_string(entry.value, entry.value_type)}
      end)
      |> Enum.concat(get_meta(document))
      |> Enum.sort(&(first_alpha_char(&1) <= first_alpha_char(&2)))
      |> JsonSerializer.encode_json()
      |> Kernel.<>("\n")

    %Langue.Formatter.SerializerResult{render: render}
  end

  def first_alpha_char(["@" | tail]), do: first_alpha_char(tail)
  def first_alpha_char([head | _tail]), do: head

  def first_alpha_char({key, _value}) do
    first_alpha_char(String.graphemes(key))
  end

  def get_meta(%Langue.Document{meta: nil}), do: []

  def get_meta(%Langue.Document{meta: meta}) do
    Enum.map(meta, fn {key, value} ->
      {key, value}
    end)
  end
end
