defmodule Langue.Formatter.Serializer do
  @callback serialize(Langue.Formatter.ParserResult.t()) :: Langue.Formatter.SerializerResult.t()
end
