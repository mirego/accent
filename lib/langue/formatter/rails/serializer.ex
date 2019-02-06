defmodule Langue.Formatter.Rails.Serializer do
  @behaviour Langue.Formatter.Serializer

  alias Langue.Utils.NestedSerializerHelper

  @white_space_regex ~r/(:|-) \n/

  def serialize(%{entries: entries, language: language}) do
    render =
      %{language.slug => entries}
      |> Enum.with_index(-1)
      |> Enum.map(&NestedSerializerHelper.map_value(elem(&1, 0), elem(&1, 1)))
      |> :fast_yaml.encode()
      |> IO.chardata_to_string()
      |> String.replace(@white_space_regex, "\\1\n")
      |> Kernel.<>("\n")

    %Langue.Formatter.SerializerResult{render: render}
  end
end
