defmodule Langue.Formatter.Strings.Serializer do
  @behaviour Langue.Formatter.Serializer

  alias Langue.Utils.LineByLineHelper

  def serialize(%{entries: entries}) do
    render = LineByLineHelper.serialize_lines(entries, "", &prop_line/1)

    %Langue.Formatter.SerializerResult{render: render}
  end

  defp prop_line(%Langue.Entry{key: key, value: nil}), do: "\"" <> key <> "\"" <> " = " <> "\"\";\n"
  defp prop_line(%Langue.Entry{key: key, value: value}), do: "\"" <> key <> "\"" <> " = " <> "\"" <> value <> "\";\n"
end
