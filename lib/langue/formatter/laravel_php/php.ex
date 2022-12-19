defmodule Langue.Formatter.LaravelPhp do
  use Langue.Formatter,
    id: "laravel_php",
    display_name: "Laravel PHP",
    extension: "php",
    parser: Langue.Formatter.LaravelPhp.Parser,
    serializer: Langue.Formatter.LaravelPhp.Serializer
end
