defmodule Langue.Formatter.JavaPropertiesXml.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.LineByLineHelper

  @prop_line_regex ~r/^ +<entry key="(?<key>.+)">(?<value>.*)<\/entry>$/

  def parse(%{render: render}) do
    entries = LineByLineHelper.parse_lines(render, &parse_line/2)

    %Langue.Formatter.ParserResult{entries: entries}
  end

  defp parse_line("<?xml" <> _rest, acc), do: acc
  defp parse_line("<!DOCTYPE" <> _rest, acc), do: acc
  defp parse_line("<properties>", acc), do: acc
  defp parse_line("</properties>", acc), do: acc
  defp parse_line(line, acc), do: LineByLineHelper.parse_line(line, @prop_line_regex, acc)
end
