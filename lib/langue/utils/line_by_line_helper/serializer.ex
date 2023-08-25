defmodule Langue.Utils.LineByLineHelper.Serializer do
  @moduledoc false
  alias Langue.Entry

  def lines(entries, prop_line) do
    Enum.map(entries, &serialize_line(&1, prop_line))
  end

  defp serialize_line(%Entry{comment: comment} = entry, prop_line) when comment not in [nil, ""] do
    comment <> "\n" <> prop_line.(entry)
  end

  defp serialize_line(entry, prop_line), do: prop_line.(entry)
end
