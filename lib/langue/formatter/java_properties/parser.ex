defmodule Langue.Formatter.JavaProperties.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.LineByLineHelper

  @prop_line_regex ~r/^(?<key>.+)=(?<value>.*)$/

  def parse(%{render: render}) do
    entries = LineByLineHelper.Parser.lines(render, @prop_line_regex)

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
