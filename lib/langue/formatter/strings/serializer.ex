defmodule Langue.Formatter.Strings.Serializer do
  @moduledoc false
  @behaviour Langue.Formatter.Serializer

  alias Langue.Utils.LineByLineHelper

  def serialize(%{entries: entries}) do
    %Langue.Formatter.SerializerResult{render: LineByLineHelper.Serializer.render(entries, &prop_line/1)}
  end

  defp prop_line(%Langue.Entry{key: key, value: value}), do: ~s("#{key}" = "#{value}";\n)
end
