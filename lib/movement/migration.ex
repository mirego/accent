defmodule Movement.Migration do
  @type t :: map

  @callback call(atom, map) :: t()
end
