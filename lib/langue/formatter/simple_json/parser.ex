defmodule Langue.Formatter.SimpleJson.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Formatter.Json.Parser, as: JsonParser

  def parse(data), do: JsonParser.parse(data)
end
