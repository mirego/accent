defmodule Langue.Formatter.Json.Serializer do
  @behaviour Langue.Formatter.Serializer

  alias Langue.Utils.NestedSerializerHelper

  def serialize(%{entries: entries}) do
    render =
      entries
      |> serialize_json
      |> Kernel.<>("\n")

    %Langue.Formatter.SerializerResult{render: render}
  end

  def serialize_json(entries) do
    %{"" => entries}
    |> Enum.with_index(-1)
    |> Enum.map(&NestedSerializerHelper.map_value(elem(&1, 0), elem(&1, 1)))
    |> List.first()
    |> elem(1)
    |> Enum.map(&add_extra/1)
    |> encode_json()
  end

  def encode_json(content) do
    {content}
    |> :jiffy.encode([:pretty])
    |> String.replace(~r/\" : (\"|{|\[|null|false|true|\d)/, "\": \\1")
  end

  defp add_extra({key, [{_, _} | _] = values}), do: {key, {Enum.map(values, &add_extra/1)}}
  defp add_extra({key, values}) when is_list(values), do: {key, Enum.map(values, &add_extra/1)}
  defp add_extra({key, nil}), do: {key, :null}
  defp add_extra({key, values}), do: {key, values}
  defp add_extra(values = [{_key, _} | _]), do: {Enum.map(values, &add_extra/1)}
  defp add_extra(values) when is_list(values), do: Enum.map(values, &add_extra/1)
  defp add_extra(nil), do: :null
  defp add_extra(value), do: value
end
