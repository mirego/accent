defmodule Langue.Formatter.ARB.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.{NestedParserHelper, Placeholders}

  def parse(%{render: render, document: document}) do
    meta = parse_meta(render)

    entries =
      render
      |> parse_json()
      |> Placeholders.parse(Langue.Formatter.Json.placeholder_regex())

    %Langue.Formatter.ParserResult{
      entries: entries,
      document: %{
        document
        | meta: meta
      }
    }
  end

  def parse_and_index(data) when is_list(data) do
    {final_map, _} =
      Enum.reduce(data, {%{}, 0}, fn {key, value}, {map, index} ->
        {Map.put(map, key, %{"value" => parse_and_index(value), "index" => index}), index + 1}
      end)

    final_map
  end

  def parse_and_index(data) when is_tuple(data), do: parse_and_index(elem(data, 0))
  def parse_and_index(data) when is_binary(data), do: data

  def parse_meta(render) do
    :jsone.decode(render, object_format: :tuple)
    |> parse_and_index()
  end

  def parse_json(render) do
    render
    |> :jsone.decode(object_format: :tuple)
    |> elem(0)
    |> Enum.filter(fn {key, _value} ->
      if String.at(key, 0) != "@", do: key
    end)
    |> NestedParserHelper.parse()
  end
end
