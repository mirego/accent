defmodule Langue.Formatter.CSV do
  @moduledoc false
  use Langue.Formatter,
    id: "csv",
    display_name: "CSV",
    extension: "csv",
    parser: Langue.Formatter.CSV.Parser,
    serializer: Langue.Formatter.CSV.Serializer
end
