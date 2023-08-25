defmodule Movement.Persister do
  @moduledoc false
  @callback persist(Movement.Context.t()) :: {:ok, list} | {:error, list}
end
