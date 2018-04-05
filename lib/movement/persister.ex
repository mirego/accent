defmodule Movement.Persister do
  @callback persist(Movement.Context.t()) :: {:ok, list} | {:error, list}
end
