defmodule Movement.Persisters.DocumentDelete do
  @behaviour Movement.Persister

  alias Accent.Repo
  alias Movement.Persisters.Base, as: BasePersister

  @batch_action "document_delete"

  def persist(context) do
    Repo.transaction(fn ->
      context
      |> Movement.Context.assign(:batch_action, @batch_action)
      |> BasePersister.execute()
    end)
  end
end
