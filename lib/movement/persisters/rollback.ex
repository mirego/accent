defmodule Movement.Persisters.Rollback do
  @behaviour Movement.Persister

  alias Accent.Repo
  alias Movement.Persisters.Base, as: BasePersister
  alias Accent.{Repo, Operation}

  def persist(%Movement.Context{operations: []}), do: {:ok, []}

  def persist(context) do
    Repo.transaction(fn ->
      context
      |> update_rollbacked_operation()
      |> BasePersister.rollback()
    end)
  end

  defp update_rollbacked_operation(context = %Movement.Context{assigns: %{operation: operation}}) do
    operation
    |> Operation.changeset(%{updated_at: NaiveDateTime.utc_now(), rollbacked: true})
    |> Repo.update()

    context
  end
end
