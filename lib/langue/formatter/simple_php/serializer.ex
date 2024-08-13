defmodule Langue.Formatter.SimplePhp.Serializer do
  @moduledoc false
  @behaviour Langue.Formatter.Serializer

  alias Langue.Utils.NestedSerializerHelper

  def serialize(%{entries: entries}) do
    render =
      entries
      |> Enum.map(fn entry ->
        {
          entry.key,
          NestedSerializerHelper.entry_value_to_string(entry.value, entry.value_type)
        }
      end)
      |> PhpAssocMap.from_tuple({:spaces, 2})

    render =
      """
      <?php
      return #{render};
      """

    %Langue.Formatter.SerializerResult{render: render}
  end
end
