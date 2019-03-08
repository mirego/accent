defmodule Langue.Formatter.Rails do
  @behaviour Langue.Formatter

  alias Langue.Formatter.Rails.{Parser, Serializer}

  def name, do: "rails_yml"
  def placeholder_regex, do: ~r/%{[^}]*}/

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
