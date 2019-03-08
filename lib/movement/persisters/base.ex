defmodule Movement.Persisters.Base do
  require Ecto.Query

  alias Accent.{Operation, Repo}
  alias Movement.Mappers.OperationsStats, as: StatMapper
  alias Movement.Migrator

  # Inserts operations by batch of 500 to prevent parameters
  # overflow in database adapter
  @operations_inserts_chunk 500

  @spec execute(Movement.Context.t()) :: {Movement.Context.t(), [Operation.t()]}
  def execute(context = %Movement.Context{operations: []}), do: {context, []}

  def execute(context = %Movement.Context{assigns: assigns = %{batch_action: action}}) when is_binary(action) do
    stats = StatMapper.map(context.operations)

    batch_operation =
      %Operation{action: action, batch: true, user_id: assigns[:user_id]}
      |> assign_document(assigns[:document])
      |> assign_project(assigns[:project])
      |> assign_revision(assigns[:revision])
      |> assign_version(assigns[:version])
      |> Map.put(:stats, stats)
      |> Repo.insert!()

    context
    |> Movement.Context.assign(:batch_operation, batch_operation)
    |> Movement.Context.assign(:batch_action, nil)
    |> execute()
  end

  def execute(context) do
    context
    |> persist_operations()
    |> migrate_up_operations()
  end

  @spec rollback(Movement.Context.t()) :: {Movement.Context.t(), [Operation.t()]}
  def rollback(%Movement.Context{assigns: %{operation: %{action: "rollback"}}}), do: Repo.rollback(:cannot_rollback_rollback)
  def rollback(context = %Movement.Context{operations: []}), do: {context, []}

  def rollback(context) do
    context
    |> persist_operations()
    |> migrate_down_operations()
  end

  defp persist_operations(context = %Movement.Context{assigns: assigns}) do
    operations =
      context.operations
      |> Stream.map(fn operation ->
        operation
        |> Map.put(:user_id, assigns[:user_id])
        |> Map.put(:inserted_at, DateTime.utc_now())
        |> Map.put(:updated_at, DateTime.utc_now())
        |> assign_project(assigns[:project])
        |> assign_batch_operation(assigns[:batch_operation])
        |> assign_document(assigns[:document])
        |> assign_revision(assigns[:revision])
        |> assign_version(assigns[:version])
        |> Map.from_struct()
      end)
      |> Stream.chunk_every(@operations_inserts_chunk)
      |> Stream.flat_map(fn operations ->
        Operation
        |> Repo.insert_all(operations, returning: true)
        |> elem(1)
        |> Repo.preload(:translation)
      end)
      |> Enum.to_list()

    %{context | operations: operations}
  end

  defp migrate_up_operations(context = %Movement.Context{operations: operations}) do
    {context, Migrator.up(operations)}
  end

  defp migrate_down_operations(context = %Movement.Context{assigns: %{operation: operation = %{batch: true}}}) do
    operations =
      operation
      |> Ecto.assoc(:operations)
      |> Repo.all()
      |> Repo.preload(:translation)
      |> Migrator.down()

    {context, operations}
  end

  defp migrate_down_operations(context = %Movement.Context{assigns: %{operation: operation}}) do
    operation = Repo.preload(operation, :translation)

    {context, Migrator.down(operation)}
  end

  defp assign_project(operation, nil), do: operation
  defp assign_project(operation, project), do: %{operation | project_id: project.id}

  defp assign_batch_operation(operation, nil), do: operation
  defp assign_batch_operation(operation, batch_operation), do: %{operation | batch_operation_id: batch_operation.id}

  defp assign_document(operation, nil), do: operation
  defp assign_document(operation, document), do: %{operation | document_id: document.id}

  defp assign_revision(operation, nil), do: operation
  defp assign_revision(operation = %{revision_id: revision_id}, _revision) when not is_nil(revision_id), do: operation
  defp assign_revision(operation, revision), do: %{operation | revision_id: revision.id}

  defp assign_version(operation, nil), do: operation
  defp assign_version(operation = %{version_id: version_id}, _version) when not is_nil(version_id), do: operation
  defp assign_version(operation, version), do: %{operation | version_id: version.id}
end
