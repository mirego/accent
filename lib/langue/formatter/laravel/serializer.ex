defmodule Langue.Formatter.Laravel.Serializer do
  @behaviour Langue.Formatter.Serializer

  def serialize(%{entries: entries}) do
    render =
      entries
      |> Enum.map(&map_entry(&1))

    %Langue.Formatter.SerializerResult{render: wrap_values(render)}
  end

  def map_entry(%Langue.Entry{key: key, value: value}) do
    "\n\t\"#{key}\" => \"#{value}\","
  end

  def wrap_values(values) do
    """
    <?php

    return [#{values}
    ];
    """
  end
end
