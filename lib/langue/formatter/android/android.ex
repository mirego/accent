defmodule Langue.Formatter.Android do
  use Langue.Formatter,
    id: "android_xml",
    display_name: "Android XML",
    extension: "xml",
    parser: Langue.Formatter.Android.Parser,
    serializer: Langue.Formatter.Android.Serializer

  def placeholder_regex, do: ~r/%(\d\$)?@/
end
