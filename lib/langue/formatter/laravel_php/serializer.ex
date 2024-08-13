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

    render =
      """
      <?php

      return #{render};
      """

    %Langue.Formatter.SerializerResult{render: render}
  end
end
