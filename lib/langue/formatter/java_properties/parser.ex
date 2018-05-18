defmodule Langue.Formatter.JavaProperties.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.{Interpolations, LineByLineHelper}

  @prop_line_regex ~r/^(?<key>.+)=(?<value>.*)$/

  def parse(%{render: render}) do
    entries =
      render
      |> LineByLineHelper.Parser.lines(@prop_line_regex)
      |> Interpolations.parse(Langue.Formatter.JavaProperties.interpolation_regex())

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
