defmodule Movement.Persisters.Rollback do
  @behaviour Movement.Persister

  alias Accent.Repo
  alias Movement.Persisters.Base, as: BasePersister

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
    |> Ecto.Changeset.change(updated_at: DateTime.utc_now(), rollbacked: true)
    |> Repo.update!()

    context
  end
end
