defmodule Langue.Formatter.Es6Module.Serializer do
  @behaviour Langue.Formatter.Serializer

  alias Langue.Formatter.Json.Serializer, as: JsonSerializer

  def serialize(%{entries: entries}) do
    content = JsonSerializer.serialize_json(entries)
    render = "export default " <> content <> ";\n"

    %Langue.Formatter.SerializerResult{render: render}
  end
end
