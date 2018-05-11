defmodule Langue.Formatter.JavaPropertiesXml.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.LineByLineHelper

  @header """
  <?xml version="1.0" encoding="UTF-8" standalone="no"?>
  <!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
  <properties>
  """

  @prop_line_regex ~r/^ +<entry key="(?<key>.+)">(?<value>.*)<\/entry>$/

  def parse(%{render: render}) do
    render = String.replace(render, @header, "")
    entries = LineByLineHelper.Parser.lines(render, @prop_line_regex)

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
