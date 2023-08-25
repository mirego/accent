defmodule Langue.Formatter.JavaPropertiesXml.Parser do
  @moduledoc false
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.LineByLineHelper
  alias Langue.Utils.Placeholders

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
      |> Placeholders.parse(Langue.Formatter.JavaPropertiesXml.placeholder_regex())

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
