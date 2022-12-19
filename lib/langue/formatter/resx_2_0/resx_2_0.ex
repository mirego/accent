defmodule Langue.Formatter.Resx20 do
  use Langue.Formatter,
    id: "resx_2_0",
    display_name: "Resx 2.0",
    extension: "resx",
    parser: Langue.Formatter.Resx20.Parser,
    serializer: Langue.Formatter.Resx20.Serializer
end
