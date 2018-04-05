defmodule Langue.Formatter.Strings.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.LineByLineHelper

  @prop_line_regex ~r/^(?<comment>.+)?"(?<key>.+)" ?= ?"(?<value>.*)"$/sm

  def parse(%{render: render}) do
    entries = LineByLineHelper.parse_lines(render, &parse_line/2, ";\n")

    %Langue.Formatter.ParserResult{entries: entries}
  end

  defp parse_line(line, acc), do: LineByLineHelper.parse_line(line, @prop_line_regex, acc)
end
