defmodule Langue.Formatter.Php do
  alias Langue.Formatter.Php.{Parser, Serializer}

  def name, do: "php"

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
