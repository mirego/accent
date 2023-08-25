defmodule Langue.Formatter.XLIFF12 do
  @moduledoc false
  use Langue.Formatter,
    id: "xliff_1_2",
    display_name: "XLIFF 1.2",
    extension: "xlf",
    parser: Langue.Formatter.XLIFF12.Parser,
    serializer: Langue.Formatter.XLIFF12.Serializer
end
