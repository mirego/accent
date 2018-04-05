defmodule Movement.Context do
  defstruct entries: [], operations: [], assigns: %{}, render: ""

  @type t :: %__MODULE__{}

  def assign(context, key, value) do
    new_assign = Map.put(%{}, key, value)

    Map.put(context, :assigns, Map.merge(context.assigns, new_assign))
  end
end
