defmodule Langue.Formatter.SimplePhp do
  @moduledoc false
  use Langue.Formatter,
    id: "simple_php",
    display_name: "Simple PHP",
    extension: "php",
    parser: Langue.Formatter.SimplePhp.Parser,
    serializer: Langue.Formatter.SimplePhp.Serializer
end
