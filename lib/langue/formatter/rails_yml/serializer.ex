defmodule Langue.Formatter.RailsYml.Serializer do
  @moduledoc false
  @behaviour Langue.Formatter.Serializer

  alias Langue.Utils.NestedSerializerHelper

  def serialize(%{entries: entries} = result) do
    locale = locale(result)

    render =
      entries
      |> nest()
      |> to_yaml_data()
      |> then(&%{locale => &1})
      |> Ymlr.document!()

    %Langue.Formatter.SerializerResult{render: render}
  end

  defp nest(entries) do
    %{"" => entries}
    |> Enum.with_index(-1)
    |> Enum.map(&NestedSerializerHelper.map_value(elem(&1, 0), elem(&1, 1)))
    |> List.first()
    |> elem(1)
  end

  defp to_yaml_data([]), do: %{}

  defp to_yaml_data([{key, _value} | _] = proplist) when is_binary(key) do
    Map.new(proplist, fn {key, value} -> {key, to_yaml_data(value)} end)
  end

  defp to_yaml_data(values) when is_list(values), do: Enum.map(values, &to_yaml_data/1)
  defp to_yaml_data(value), do: value

  defp locale(%{language: %{slug: slug}}) when is_binary(slug) and slug != "", do: slug
  defp locale(%{document: %{master_language: master}}) when is_binary(master) and master != "", do: master
  defp locale(_), do: "en"
end
