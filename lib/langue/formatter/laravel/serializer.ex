defmodule Langue.Formatter.Laravel.Serializer do
  @behaviour Langue.Formatter.Serializer

  alias Langue.Utils.NestedSerializerHelper

  @white_space_regex ~r/(:|-) \n/

  def serialize(%{entries: entries, locale: locale}) do
    render = nil
    %Langue.Formatter.SerializerResult{render: render}
  end
end
