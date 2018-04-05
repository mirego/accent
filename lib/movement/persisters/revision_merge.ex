defmodule Movement.Persisters.RevisionMerge do
  @behaviour Movement.Persister

  alias Accent.Repo
  alias Movement.Persisters.Base, as: BasePersister

  @batch_action "merge"

  def persist(context) do
    Repo.transaction(fn ->
      context
      |> Movement.Context.assign(:batch_action, @batch_action)
      |> BasePersister.execute()
    end)
  end
end
