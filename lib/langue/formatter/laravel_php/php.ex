defmodule Langue.Formatter.LaravelPhp do
  alias Langue.Formatter.LaravelPhp.{Parser, Serializer}

  def name, do: "laravel_php"

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
