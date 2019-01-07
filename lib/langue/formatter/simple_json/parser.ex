defmodule Langue.Formatter.SimpleJson.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Formatter.Json.Parser, as: JsonParser
  alias Langue.Utils.Placeholders

  def parse(%{render: render}) do
    entries =
      render
      |> JsonParser.parse_json()
      |> Placeholders.parse(Langue.Formatter.SimpleJson.placeholder_regex())

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
