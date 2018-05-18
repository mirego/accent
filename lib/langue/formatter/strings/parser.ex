defmodule Langue.Formatter.Strings.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.{Interpolations, LineByLineHelper}

  @prop_line_regex ~r/^(?<comment>.+)?"(?<key>.+)" ?= ?"(?<value>.*)"$/sm

  def parse(%{render: render}) do
    entries =
      render
      |> LineByLineHelper.Parser.lines(@prop_line_regex, ";\n")
      |> Interpolations.parse(Langue.Formatter.Strings.interpolation_regex())

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
