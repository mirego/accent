defmodule Langue.Formatter.GoI18nJson.Serializer do
  @moduledoc """
  The serializer needs to nest the plurals form inside the parent key.
  This is done by looping over every key and keeping a `plurals` state.

  When the current key is a plural we don’t append it to the entries list, but we keep it in
  the `plurals` state.

  When the current key is not a plural (and the `plurals` state is not empty),
  we simply append the current plurals to the entries.
  """

  @behaviour Langue.Formatter.Serializer

  # Constants
  @plural_leaf ~r/\.\w+$/
  @plural_root ~r/^\w+\./

  alias Langue.Utils.NestedSerializerHelper

  def serialize(%{entries: entries}) do
    render =
      entries
      |> Enum.reduce(%{plurals: [], entries: []}, &process_entry/2)
      |> append_plurals()
      |> Map.get(:entries)
      |> :jiffy.encode([:pretty])
      |> Langue.Formatter.Json.Serializer.prettify_json()
      |> Kernel.<>("\n")

    %Langue.Formatter.SerializerResult{render: render}
  end

  defp process_entry(entry = %{plural: true}, acc), do: accumulate_plural(entry, acc)

  defp process_entry(entry, acc) do
    acc
    |> append_plurals()
    |> append_entry(entry)
  end

  defp entry_value(%{value_type: "null"}), do: :null
  defp entry_value(entry), do: NestedSerializerHelper.entry_value_to_string(entry.value, entry.value_type)

  defp accumulate_plural(entry, acc) do
    update_in(acc, [:plurals], &(&1 ++ [entry]))
  end

  defp append_entry(acc, entry) do
    entry = key_value(entry.key, entry_value(entry))

    update_in(acc, [:entries], &(&1 ++ entry))
  end

  defp append_plurals(acc = %{plurals: []}), do: acc

  defp append_plurals(acc = %{plurals: plurals}) do
    mapped_plurals =
      Enum.map(plurals, fn entry ->
        {plural_to_leaf_key(entry), entry_value(entry)}
      end)

    key = plurals_to_root_key(plurals)
    entry = key_value(key, {mapped_plurals})

    update_in(acc, [:entries], &(&1 ++ entry))
  end

  # [{[{"id", "KEY"}, {"translation", "VALUE"}]}] results in the following JSON:
  # {"id": "KEY", "translation": "VALUE"}
  defp key_value(key, value) do
    [{[{"id", key}, {"translation", value}]}]
  end

  # The root key is the key without the leaf: "my_key.one" will return "my_key"
  defp plurals_to_root_key([entry | _]) do
    String.replace(entry.key, @plural_leaf, "")
  end

  # The leaf key is the key without the root: "my_key.one" will return "one"
  defp plural_to_leaf_key(entry) do
    String.replace(entry.key, @plural_root, "")
  end
end
