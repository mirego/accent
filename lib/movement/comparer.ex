defmodule Movement.Comparer do
  alias Movement.Comparers.{MergeForce, MergePassive, MergeSmart, SyncPassive, SyncSmart}

  @callback compare(map, map) :: Movement.Operation.t()

  @default_comparer "smart"

  @sync_comparers %{
    "passive" => &SyncPassive.compare/2,
    "smart" => &SyncSmart.compare/2
  }

  @merge_comparers %{
    "passive" => &MergePassive.compare/2,
    "smart" => &MergeSmart.compare/2,
    "force" => &MergeForce.compare/2
  }

  @doc """
  A string is used to identify the algorithm used to compare incoming translations to their current form.
  The implementations of `Movement.Comparer` are accessible from this function.

  ## Examples
  iex> Movement.Comparer.comparer(:sync, "smart")
  &Movement.Comparers.SyncSmart.compare/2
  iex> Movement.Comparer.comparer(:sync, "passive")
  &Movement.Comparers.SyncPassive.compare/2
  iex> Movement.Comparer.comparer(:merge, "passive")
  &Movement.Comparers.MergePassive.compare/2
  iex> Movement.Comparer.comparer(:merge, "smart")
  &Movement.Comparers.MergeSmart.compare/2
  iex> Movement.Comparer.comparer(:merge, "force")
  &Movement.Comparers.MergeForce.compare/2
  """
  def comparer(:sync, type) do
    Map.get(@sync_comparers, type, @sync_comparers[@default_comparer])
  end

  def comparer(:merge, type) do
    Map.get(@merge_comparers, type, @merge_comparers[@default_comparer])
  end
end
