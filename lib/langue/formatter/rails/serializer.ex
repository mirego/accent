defmodule Langue.Formatter.Rails.Serializer do
  @behaviour Langue.Formatter.Serializer

  alias Langue.Utils.NestedSerializerHelper

  @white_space_regex ~r/(:|-) \n/

  def name, do: "rails_yml"

  def serialize(%{entries: entries, locale: locale}) do
    render =
      %{locale => entries}
      |> Enum.with_index(-1)
      |> Enum.map(&NestedSerializerHelper.map_value(elem(&1, 0), elem(&1, 1)))
      |> :fast_yaml.encode()
      |> IO.iodata_to_binary()
      |> String.replace(@white_space_regex, "\\1\n")
      |> Kernel.<>("\n")

    %Langue.Formatter.SerializerResult{render: render}
  end
end
