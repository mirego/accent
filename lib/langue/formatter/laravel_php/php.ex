defmodule Langue.Formatter.LaravelPhp do
  @behaviour Langue.Formatter

  alias Langue.Formatter.LaravelPhp.{Parser, Serializer}

  def name, do: "laravel_php"
  def placeholder_regex, do: :not_supported

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
