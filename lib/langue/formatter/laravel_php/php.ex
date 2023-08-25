defmodule Langue.Formatter.LaravelPhp do
  @moduledoc false
  use Langue.Formatter,
    id: "laravel_php",
    display_name: "Laravel PHP",
    extension: "php",
    parser: Langue.Formatter.LaravelPhp.Parser,
    serializer: Langue.Formatter.LaravelPhp.Serializer
end
