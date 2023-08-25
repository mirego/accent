defmodule Movement.Persisters.RevisionMerge do
  @moduledoc false
  @behaviour Movement.Persister

  alias Accent.Repo
  alias Movement.Persisters.Base, as: BasePersister

  def persist(context) do
    Repo.transaction(fn -> BasePersister.execute(context) end)
  end
end
