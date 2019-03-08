defmodule Langue.Formatter.SimpleJson.Serializer do
  @behaviour Langue.Formatter.Serializer

  alias Langue.Formatter.Json.Serializer, as: JsonSerializer
  alias Langue.Utils.NestedSerializerHelper

  def serialize(%{entries: entries}) do
    render =
      entries
      |> Enum.map(fn entry ->
        {entry.key, NestedSerializerHelper.entry_value_to_string(entry.value, entry.value_type)}
      end)
      |> JsonSerializer.encode_json()
      |> Kernel.<>("\n")

    %Langue.Formatter.SerializerResult{render: render}
  end
end
