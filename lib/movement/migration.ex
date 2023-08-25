defmodule Movement.Migration do
  @moduledoc false
  @type t :: map
  @typep operation_name :: :update | :update_all | :insert_all | :update_all_dynamic

  @callback call(atom, map) :: {operation_name(), any()} | [{operation_name(), any()}]
end
