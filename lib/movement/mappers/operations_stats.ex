defmodule Movement.Mappers.OperationsStats do
  @moduledoc false
  def map(operations) do
    operations
    |> Enum.group_by(&Map.get(&1, :action))
    |> Enum.map(&map_stat/1)
  end

  defp map_stat({action, operations}) do
    %{
      action: action,
      count: length(operations)
    }
  end
end
