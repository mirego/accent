defmodule Langue.Formatter.Parser do
  @moduledoc false
  alias Langue.Formatter.ParserResult, as: Output
  alias Langue.Formatter.SerializerResult, as: Input

  @callback parse(Input.t()) :: Output.t()
end
