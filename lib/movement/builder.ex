defmodule Movement.Builder do
  @moduledoc false
  @callback build(Movement.Context.t()) :: Movement.Context.t()
end
