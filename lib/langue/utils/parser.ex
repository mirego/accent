defmodule Langue.Formatter.Parser do
  @moduledoc false
  alias Langue.Formatter.ParserResult, as: Output
  alias Langue.Formatter.SerializerResult, as: Input

  @type result :: {:ok, Output.t()} | {:error, any()}

  @callback parse(Input.t()) :: result
end
