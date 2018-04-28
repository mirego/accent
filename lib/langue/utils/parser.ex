defmodule Langue.Formatter.Parser do
  alias Langue.Formatter.SerializerResult, as: Input
  alias Langue.Formatter.ParserResult, as: Output

  @type result :: {:ok, Output.t()} | {:error, any()}

  @callback name() :: binary()
  @callback parse(Input.t()) :: result
end
