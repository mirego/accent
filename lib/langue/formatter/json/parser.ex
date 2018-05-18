defmodule Langue.Formatter.Json.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.{Interpolations, NestedParserHelper}

  def parse(%{render: render}) do
    entries = parse_json(render)

    %Langue.Formatter.ParserResult{entries: entries}
  end

  def parse_json(render) do
    render
    |> :jiffy.decode()
    |> elem(0)
    |> NestedParserHelper.parse()
    |> Interpolations.parse(Langue.Formatter.Json.interpolation_regex())
  end
end
