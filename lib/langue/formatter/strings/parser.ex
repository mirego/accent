defmodule Langue.Formatter.Strings.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.LineByLineHelper

  @prop_line_regex ~r/^(?<comment>.+)?"(?<key>.+)" ?= ?"(?<value>.*)"$/sm

  def name, do: "strings"

  def parse(%{render: render}) do
    entries = LineByLineHelper.Parser.lines(render, @prop_line_regex, ";\n")

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
