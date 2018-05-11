defmodule Langue.Formatter.Rails do
  alias Langue.Formatter.Rails.{Parser, Serializer}

  def name, do: "rails_yml"

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
