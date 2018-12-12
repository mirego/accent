defmodule Langue.Formatter.Gettext do
  @behaviour Langue.Formatter

  alias Langue.Formatter.Gettext.{Parser, Serializer}

  def name, do: "gettext"
  def placeholder_regex, do: ~r/%{[^}]*}/

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
