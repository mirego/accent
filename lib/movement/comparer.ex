defmodule Movement.Comparer do
  @callback compare(map, map) :: Movement.Operation.t()
end
