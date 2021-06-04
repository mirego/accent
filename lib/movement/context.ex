defmodule Movement.Context do
  defstruct entries: [], operations: [], assigns: %{options: []}, render: ""

  @type t :: %__MODULE__{}

  def assign(context, key, value) do
    Map.put(context, :assigns, Map.merge(context.assigns, %{key => value}))
  end
end
