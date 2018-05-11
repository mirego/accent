defmodule Langue.Formatter.Android do
  alias Langue.Formatter.Android.{Parser, Serializer}

  def name, do: "android_xml"

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
