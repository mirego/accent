defmodule Langue.Formatter.Serializer do
  @moduledoc false
  alias Langue.Formatter.ParserResult, as: Input
  alias Langue.Formatter.SerializerResult, as: Output

  @type result :: {:ok, Output.t()} | {:error, any()}

  @callback serialize(Input.t()) :: result
end
