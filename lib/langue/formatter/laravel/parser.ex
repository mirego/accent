defmodule Langue.Formatter.Laravel do
  alias Langue.Formatter.Laravel.{Parser, Serializer}

  def name, do: "laravel_php"

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
