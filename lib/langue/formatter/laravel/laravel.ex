defmodule Langue.Formatter.Laravel.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.NestedParserHelper

  def parse(%{render: render}) do
    entries = []
    %Langue.Formatter.ParserResult{entries: entries}
  end
end
