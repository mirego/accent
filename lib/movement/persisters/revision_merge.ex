defmodule Movement.Persisters.RevisionMerge do
  @behaviour Movement.Persister

  alias Accent.Repo
  alias Movement.Persisters.Base, as: BasePersister

  def persist(context) do
    Repo.transaction(fn -> BasePersister.execute(context) end)
  end
end
