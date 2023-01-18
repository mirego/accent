defmodule Movement.Persisters.Base do
  require Ecto.Query

  alias Accent.{Operation, Repo}
  alias Movement.Mappers.OperationsStats, as: StatMapper
  alias Movement.Migrator
  alias Movement.Persisters.ProjectStateChangeWorker

  # Inserts operations by batch of 500 to prevent parameters
  # overflow in database adapter
  @operations_inserts_chunk 500

  @options_keys ~w(new_slave_options merge_options sync_options)a

  @spec execute(Movement.Context.t()) :: {Movement.Context.t(), [Operation.t()]}
  def execute(context = %Movement.Context{operations: []}), do: {context, []}

  def execute(context = %Movement.Context{assigns: assigns = %{batch_action: action}})
      when is_binary(action) do
    stats = StatMapper.map(context.operations)

    batch_operation =
      %Operation{action: action, batch: true, user_id: assigns[:user_id]}
      |> assign_document(assigns[:document])
      |> assign_project(assigns[:project])
      |> assign_revision(assigns[:revision])
      |> assign_version(assigns[:version])
      |> assign_options(assigns)
      |> Map.put(:stats, stats)
      |> Repo.insert!()

    Accent.OperationBatcher.batch(batch_operation)

    context
    |> Movement.Context.assign(:batch_operation, batch_operation)
    |> Movement.Context.assign(:batch_action, nil)
    |> execute()
  end

  def execute(context) do
    project_state_change_context = %{
      project_id: context.assigns[:project] && context.assigns.project.id,
      document_id: context.assigns[:document] && context.assigns.document.id,
      master_revision_id: context.assigns[:master_revision] && context.assigns.master_revision.id,
      revision_id: context.assigns[:revision] && context.assigns.revision.id,
      version_id: context.assigns[:version] && context.assigns.version.id,
      batch_operation_id: context.assigns[:batch_operation] && context.assigns.batch_operation.id,
      user_id: context.assigns[:user_id],
      previous_project_state: ProjectStateChangeWorker.get_project_state(context.assigns[:project])
    }

    context
    |> persist_operations()
    |> migrate_up_operations()
    |> tap(fn _ -> Oban.insert(ProjectStateChangeWorker.new(project_state_change_context)) end)
  end

  @spec rollback(Movement.Context.t()) :: {Movement.Context.t(), [Operation.t()]}
  def rollback(%Movement.Context{assigns: %{operation: %{action: "rollback"}}}),
    do: Repo.rollback(:cannot_rollback_rollback)

  def rollback(context = %Movement.Context{operations: []}), do: {context, []}

  def rollback(context) do
    context
    |> persist_operations()
    |> migrate_down_operations()
  end

  defp persist_operations(context = %Movement.Context{assigns: assigns}) do
    placeholders =
      %{
        now: DateTime.utc_now(),
        user_id: assigns[:user_id]
      }
      |> assign_project(assigns[:project])
      |> assign_batch_operation(assigns[:batch_operation])
      |> assign_document(assigns[:document])
      |> assign_revision(assigns[:revision])
      |> assign_version(assigns[:version])

    operations =
      context.operations
      |> Stream.map(fn operation ->
        Map.from_struct(%{
          operation
          | inserted_at: {:placeholder, :now},
            updated_at: {:placeholder, :now},
            user_id: {:placeholder, :user_id},
            document_id: {:placeholder, :document_id},
            project_id: {:placeholder, :project_id},
            batch_operation_id: {:placeholder, :batch_operation_id},
            version_id: operation.version_id || {:placeholder, :version_id},
            revision_id: operation.revision_id || {:placeholder, :revision_id}
        })
      end)
      |> Stream.chunk_every(@operations_inserts_chunk)
      |> Stream.flat_map(fn operations ->
        Operation
        |> Repo.insert_all(operations, returning: true, placeholders: placeholders)
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

    {context, Migrator.down([operation])}
  end

  defp assign_project(placeholders, project),
    do: Map.put(placeholders, :project_id, project && project.id)

  defp assign_batch_operation(placeholders, batch_operation),
    do: Map.put(placeholders, :batch_operation_id, batch_operation && batch_operation.id)

  defp assign_document(placeholders, document),
    do: Map.put(placeholders, :document_id, document && document.id)

  defp assign_revision(placeholders, revision),
    do: Map.put(placeholders, :revision_id, revision && revision.id)

  defp assign_version(placeholders, version),
    do: Map.put(placeholders, :version_id, version && version.id)

  defp assign_options(operations, assigns) do
    options = Enum.flat_map(@options_keys, &Map.get(assigns, &1, []))

    %{operations | options: options}
  end
end
