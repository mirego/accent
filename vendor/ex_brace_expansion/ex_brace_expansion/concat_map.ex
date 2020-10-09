defmodule ExBraceExpansion.ConcatMap do

  def concat_map(coll, func) do
    coll
    |> Enum.map(fn val -> func.(val) end)
    |> List.flatten
  end
end

