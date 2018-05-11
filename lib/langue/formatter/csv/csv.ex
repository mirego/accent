defmodule Langue.Formatter.CSV do
  alias Langue.Formatter.CSV.{Parser, Serializer}

  def name, do: "csv"

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
