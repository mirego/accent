defmodule Movement.Migration do
  @type t :: {:ok, map} | {:error, map}

  @callback call(atom, map) :: t
end
