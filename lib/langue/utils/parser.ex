defmodule Langue.Formatter.Parser do
  @callback parse(Langue.Formatter.SerializerResult.t()) :: Langue.Formatter.ParserResult.t()
end
