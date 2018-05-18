defmodule Langue.Formatter.JavaPropertiesXml.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.{Interpolations, LineByLineHelper}

  @header """
  <?xml version="1.0" encoding="UTF-8" standalone="no"?>
  <!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
  <properties>
  """

  @prop_line_regex ~r/^ +<entry key="(?<key>.+)">(?<value>.*)<\/entry>$/

  def parse(%{render: render}) do
    entries =
      render
      |> String.replace(@header, "")
      |> LineByLineHelper.Parser.lines(@prop_line_regex)
      |> Interpolations.parse(Langue.Formatter.JavaPropertiesXml.interpolation_regex())

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
