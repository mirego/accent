defmodule Langue.Formatter.Serializer do
  alias Langue.Formatter.ParserResult, as: Input
  alias Langue.Formatter.SerializerResult, as: Output

  @type result :: {:ok, Output.t()} | {:error, any()}

  @callback name() :: binary()
  @callback serialize(Input.t()) :: result
end
