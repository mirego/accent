defmodule Langue.Formatter.LaravelPhp.Serializer do
  @moduledoc false
  @behaviour Langue.Formatter.Serializer

  alias Langue.Utils.NestedSerializerHelper

  def serialize(%{entries: entries, language: language}) do
    render =
      %{language.slug => entries}
      |> Enum.with_index(-1)
      |> Enum.map(&NestedSerializerHelper.map_value(elem(&1, 0), elem(&1, 1)))
      |> hd()
      |> elem(1)
      |> PhpAssocMap.from_tuple({:spaces, 2})

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
