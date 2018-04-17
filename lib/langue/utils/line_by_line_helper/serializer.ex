defmodule Langue.Utils.LineByLineHelper.Serializer do
  alias Langue.Entry

  def lines(entries, prop_line) do
    Enum.map(entries, &serialize_line(&1, prop_line))
  end

  defp serialize_line(entry = %Entry{comment: nil}, prop_line), do: prop_line.(entry)

  defp serialize_line(entry = %Entry{comment: ""}, prop_line), do: prop_line.(entry)

  defp serialize_line(entry = %Entry{comment: comment}, prop_line) do
    comment <> "\n" <> prop_line.(entry)
  end
end
