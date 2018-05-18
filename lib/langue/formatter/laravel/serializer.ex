defmodule Langue.Formatter.Laravel.Serializer do
  @behaviour Langue.Formatter.Serializer

  def serialize(%{entries: entries, locale: locale}) do
    render = nil
    %Langue.Formatter.SerializerResult{render: render}
  end
end
