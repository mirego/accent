defmodule Langue.Formatter.Serializer do
  @moduledoc false
  alias Langue.Formatter.ParserResult, as: Input
  alias Langue.Formatter.SerializerResult, as: Output

  @callback serialize(Input.t()) :: Output.t()
end
