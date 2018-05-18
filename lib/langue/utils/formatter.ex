defmodule Langue.Formatter do
  alias Langue.Formatter.ParserResult
  alias Langue.Formatter.SerializerResult

  @callback name() :: String.t()
  @callback interpolation_regex() :: Regex.t() | :not_supported
  @callback parse(SerializerResult.t()) :: Langue.Formatter.Parser.result()
  @callback serialize(ParserResult.t()) :: Langue.Formatter.Serializer.result()
end
