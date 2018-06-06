defmodule Langue.Formatter.LaravelPhp.Serializer do
  @behaviour Langue.Formatter.Serializer

  alias Langue.Utils.NestedSerializerHelper

  def serialize(%{entries: entries, locale: locale}) do
    render =
      %{locale => entries}
      |> Enum.with_index(-1)
      |> Enum.map(&NestedSerializerHelper.map_value(elem(&1, 0), elem(&1, 1)))
      |> Enum.at(0)
      |> elem(1)
      |> PhpAssocMap.from_tuple()
      |> PhpAssocMap.Exploder.explode()

    %Langue.Formatter.SerializerResult{render: wrap_values(render)}
  end

  @spec wrap_values(String.t()) :: String.t()
  defp wrap_values(values) do
    """
    <?php

    return #{values};
    """
  end
end
