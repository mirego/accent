defmodule Langue.Formatter.JavaProperties.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.{LineByLineHelper, Placeholders}

  @prop_line_regex ~r/^(?<key>.+)=(?<value>.*)$/

  def parse(%{render: render}) do
    entries =
      render
      |> LineByLineHelper.Parser.lines(@prop_line_regex)
      |> Placeholders.parse(Langue.Formatter.JavaProperties.placeholder_regex())

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
