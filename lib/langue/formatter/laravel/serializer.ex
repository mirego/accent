defmodule Langue.Formatter.Laravel.Serializer do
  @behaviour Langue.Formatter.Serializer

  def serialize(%{entries: entries}) do
    render =
      entries
      |> Enum.map(&map_entry(&1))
      |> Enum.join(",")

    %Langue.Formatter.SerializerResult{render: wrap_values(render)}
  end

  @spec map_entry(Langue.Entry.t()) :: String.t()
  defp map_entry(%Langue.Entry{key: key, value: value}) do
    "\n\t\"#{key}\" => \"#{escape_value(value)}\""
  end

  @spec escape_value(String.t()) :: String.t()
  defp escape_value(value) do
    value
    |> String.replace("\"", "\\\"")
    |> String.replace("\\'", "'")
  end

  @spec wrap_values(String.t()) :: String.t()
  defp wrap_values(values) do
    """
    <?php

    return [#{values}
    ];
    """
  end
end
