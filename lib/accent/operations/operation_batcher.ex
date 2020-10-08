defmodule Accent.OperationBatcher do
  import Ecto.Query, only: [from: 2]

  alias Accent.{Operation, Repo}

  @time_limit 60
  @time_unit "minute"
  @batchable_operations ~w(correct_conflict update sync merge)

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

  defp find_existing_operation(%{action: action} = operation) when action in @batchable_operations do
    from(
      operations in Operation,
      where: operations.id != ^operation.id,
      where: [user_id: ^operation.user_id],
      where: [action: ^operation.action],
      where: [rollbacked: false],
      where: operations.inserted_at >= datetime_add(^operation.inserted_at, ^(-@time_limit), ^@time_unit),
      order_by: [asc: :inserted_at],
      limit: 1
    )
    |> existing_operation_by_revision_id(operation.revision_id)
    |> Repo.one()
    |> case do
      nil -> nil
      operation -> Repo.preload(operation, :batch_operation)
    end
  end

  defp find_existing_operation(_), do: nil

  defp existing_operation_by_revision_id(query, nil), do: query

  defp existing_operation_by_revision_id(query, revision_id) do
    from(query, where: [revision_id: ^revision_id])
  end

  defp maybe_batch(nil), do: nil
  defp maybe_batch(operation = %{batch_operation_id: nil}), do: create_batch_operation(operation)
  defp maybe_batch(%{batch_operation: batch_operation}), do: update_batch_operation(batch_operation)

  defp update_batch_operation(batch_operation) do
    stats = Enum.map(batch_operation.stats, fn stat -> update_in(stat, ["count"], fn count -> count + 1 end) end)

    batch_operation
    |> Operation.stats_changeset(%{stats: stats})
    |> Repo.update!()
  end

  defp create_batch_operation(operation) do
    operation_copy = Map.take(operation, ~w(
      revision_id
      version_id
      project_id
      user_id
    )a)

    %Operation{
      batch: true,
      action: "batch_" <> operation.action,
      stats: [%{"count" => 2, "action" => operation.action}]
    }
    |> Map.merge(operation_copy)
    |> Repo.insert!()
  end
end
