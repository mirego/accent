defmodule Langue.Formatter.JavaPropertiesXml.Serializer do
  @behaviour Langue.Formatter.Serializer

  alias Langue.Utils.LineByLineHelper

  def name, do: "java_properties_xml"

  def serialize(%{entries: entries}) do
    render =
      entries
      |> LineByLineHelper.Serializer.lines(&prop_line/1)

    render = [xml_template() | render]

    render =
      render
      |> Enum.concat(["</properties>\n"])
      |> Enum.join("")

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
