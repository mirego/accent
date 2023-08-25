defmodule Langue.Formatter.Json.Parser do
  @moduledoc false
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.NestedParserHelper
  alias Langue.Utils.Placeholders

  def parse(%{render: render}) do
    entries =
      render
      |> parse_json()
      |> Placeholders.parse(Langue.Formatter.Json.placeholder_regex())

    %Langue.Formatter.ParserResult{entries: entries}
  end

  def parse_json(render) do
    render
    |> :jsone.decode(object_format: :tuple)
    |> elem(0)
    |> NestedParserHelper.parse()
  end
end
