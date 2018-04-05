defmodule Movement.Builder do
  @callback build(Movement.Context.t()) :: Movement.Context.t()
end
