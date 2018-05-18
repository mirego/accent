defmodule Langue.Formatter.CSV do
  @behaviour Langue.Formatter

  alias Langue.Formatter.CSV.{Parser, Serializer}

  def name, do: "csv"
  def interpolation_regex, do: :not_supported

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
