defmodule Langue.Formatter.Gettext do
  alias Langue.Formatter.Gettext.{Parser, Serializer}

  def name, do: "gettext"

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
