defmodule Langue.Formatter.JavaPropertiesXml.Serializer do
  @behaviour Langue.Formatter.Serializer

  alias Langue.Utils.LineByLineHelper

  def serialize(%{entries: entries}) do
    render =
      entries
      |> LineByLineHelper.serialize_lines(xml_template(), &prop_line/1)
      |> Kernel.<>("</properties>\n")

    %Langue.Formatter.SerializerResult{render: render}
  end

  defp xml_template do
    """
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
    <properties>
    """
  end

  defp prop_line(%Langue.Entry{key: key, value: value}), do: "  <entry key=\"#{key}\">" <> value <> "</entry>\n"
end
