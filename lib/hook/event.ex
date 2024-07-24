defmodule Accent.Hook.Event do
  @moduledoc false
  @callback name :: String.t()
  @callback triggered?(args :: map(), new_state :: map()) :: boolean()
  @callback payload(args :: map(), new_state :: map()) :: map()
end
