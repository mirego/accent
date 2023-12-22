defmodule Movement.Context do
  @moduledoc false
  defstruct entries: [], operations: [], assigns: %{options: []}, render: ""

  @type t :: %__MODULE__{}

  def assign(context, key, value) do
    Map.put(context, :assigns, Map.put(context.assigns, key, value))
  end
end
