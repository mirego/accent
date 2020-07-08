defmodule Langue.Formatter.Resx20 do
  @behaviour Langue.Formatter

  alias Langue.Formatter.Resx20.{Parser, Serializer}

  def name, do: "resx_2_0"
  def placeholder_regex, do: :not_supported

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
