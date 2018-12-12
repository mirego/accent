defmodule Langue.Formatter.Android do
  @behaviour Langue.Formatter

  alias Langue.Formatter.Android.{Parser, Serializer}

  def name, do: "android_xml"
  def placeholder_regex, do: ~r/%(\d\$)?@/

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
