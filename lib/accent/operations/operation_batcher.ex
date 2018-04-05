defmodule Accent.OperationBatcher do
  import Ecto.Query, only: [from: 2]

  alias Accent.{Repo, Operation}

  @time_limit 60
  @time_unit "minute"

  def batch(%{batch_operation_id: id}) when not is_nil(id), do: {0, nil}

  def batch(operation) do
    with existing_operation when not is_nil(existing_operation) <- find_existing_operation(operation),
         batch_operation when not is_nil(batch_operation) <- maybe_batch(existing_operation) do
      from(
        o in Operation,
        where: o.id in ^[existing_operation.id, operation.id]
      )
      |> Repo.update_all(set: [batch_operation_id: batch_operation.id])
    else
      _ -> {0, nil}
    end
  end

  defp find_existing_operation(%{action: action} = operation) when action in ["correct_conflict", "update"] do
    case do_find_existing_operation(operation) do
      nil -> nil
      operation -> Repo.preload(operation, :batch_operation)
    end
  end

  defp do_find_existing_operation(%{action: action, id: id, inserted_at: inserted_at, user_id: user_id, revision_id: revision_id}) do
    from(
      operation in Operation,
      where: operation.id != ^id,
      where: [revision_id: ^revision_id],
      where: [user_id: ^user_id],
      where: [action: ^action],
      where: [rollbacked: false],
      where: operation.inserted_at >= datetime_add(^inserted_at, ^(-@time_limit), ^@time_unit),
      order_by: [asc: :inserted_at],
      limit: 1
    )
    |> Repo.one()
  end

  defp maybe_batch(nil), do: nil
  defp maybe_batch(operation = %{batch_operation_id: nil}), do: create_batch_operation(operation)
  defp maybe_batch(%{batch_operation: batch_operation}), do: update_batch_operation(batch_operation)

  defp update_batch_operation(batch_operation) do
    batch_operation
    |> Operation.stats_changeset(%{stats: increment_stats_count(batch_operation)})
    |> Repo.update!()
  end

  defp create_batch_operation(%{action: action, user_id: user_id, revision_id: revision_id}) do
    %Operation{
      batch: true,
      action: batch_operation_action(action),
      revision_id: revision_id,
      user_id: user_id,
      stats: batch_operation_stats(action)
    }
    |> Repo.insert!()
  end

  defp increment_stats_count(batch_operation) do
    Enum.map(batch_operation.stats, fn stat -> update_in(stat, ["count"], fn count -> count + 1 end) end)
  end

  defp batch_operation_action(action), do: "batch_" <> action
  defp batch_operation_stats(action), do: [%{"count" => 2, "action" => action}]
end
