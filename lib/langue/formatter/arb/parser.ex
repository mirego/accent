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

  def parse_meta(render) do
    render
    |> :jsone.decode()
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      if String.at(key, 0) == "@" do
        Map.put(acc, key, value)
      else
        acc
      end
    end)
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
