defmodule Movement.Persisters.Base do
  @moduledoc false
  alias Accent.Operation
  alias Accent.Repo
  alias Movement.Mappers.OperationsStats, as: StatMapper
  alias Movement.Migrator
  alias Movement.Persisters.ProjectHookWorker

  require Ecto.Query

  # Inserts operations by batch of 500 to prevent parameters
  # overflow in database adapter
  @operations_inserts_chunk 500

  @options_keys ~w(new_slave_options merge_options sync_options)a

  @spec execute(Movement.Context.t()) :: {Movement.Context.t(), [Operation.t()]}
  def execute(%Movement.Context{operations: []} = context), do: {context, []}

  def execute(%Movement.Context{assigns: %{batch_action: action, batch_operation: nil} = assigns} = context)
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
    |> execute()
  end

  def execute(context) do
    project_context = %{
      batch_action: context.assigns[:batch_action],
      operations_count: Enum.count(context.operations),
      project_id: context.assigns[:project] && context.assigns.project.id,
      document_id: context.assigns[:document] && context.assigns.document.id,
      master_revision_id: context.assigns[:master_revision] && context.assigns.master_revision.id,
      revision_id: context.assigns[:revision] && context.assigns.revision.id,
      version_id: context.assigns[:version] && context.assigns.version.id,
      batch_operation_id: context.assigns[:batch_operation] && context.assigns.batch_operation.id,
      user_id: context.assigns[:user_id],
      previous_project_state: ProjectHookWorker.get_project_state(context.assigns[:project])
    }

    context
    |> persist_operations()
    |> migrate_up_operations()
    |> tap(fn _ ->
      context.assigns[:project] && Oban.insert(ProjectHookWorker.new(project_context))
    end)
  end

  @spec rollback(Movement.Context.t()) :: {Movement.Context.t(), [Operation.t()]}
  def rollback(%Movement.Context{assigns: %{operation: %{action: "rollback"}}}),
    do: Repo.rollback(:cannot_rollback_rollback)

  def rollback(%Movement.Context{operations: []} = context), do: {context, []}

  def rollback(context) do
    context
    |> persist_operations()
    |> migrate_down_operations()
  end

  defp persist_operations(%Movement.Context{assigns: assigns} = context) do
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

    placeholder_values =
      Map.new(
        Enum.map(placeholders, fn {key, _value} ->
          {key, {:placeholder, key}}
        end)
      )

    operations =
      context.operations
      |> Stream.map(fn operation ->
        operation =
          Map.from_struct(%{
            operation
            | inserted_at: {:placeholder, :now},
              updated_at: {:placeholder, :now},
              user_id: placeholder_values[:user_id] || operation.user_id,
              document_id: placeholder_values[:document_id] || operation.document_id,
              project_id: placeholder_values[:project_id] || operation.project_id,
              batch_operation_id: placeholder_values[:batch_operation_id] || operation.batch_operation_id,
              version_id: operation.version_id || placeholder_values[:version_id],
              revision_id: operation.revision_id || placeholder_values[:revision_id]
          })

        Map.delete(operation, :machine_translations_enabled)
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

  defp migrate_up_operations(%Movement.Context{operations: operations} = context) do
    {context, Migrator.up(operations)}
  end

  defp migrate_down_operations(%Movement.Context{assigns: %{operation: %{batch: true} = operation}} = context) do
    operations =
      operation
      |> Ecto.assoc(:operations)
      |> Repo.all()
      |> Repo.preload(:translation)
      |> Migrator.down()

    {context, operations}
  end

  defp migrate_down_operations(%Movement.Context{assigns: %{operation: operation}} = context) do
    operation = Repo.preload(operation, :translation)

    {context, Migrator.down([operation])}
  end

  defp assign_project(placeholders, nil), do: placeholders

  defp assign_project(placeholders, project), do: Map.put(placeholders, :project_id, project && project.id)

  defp assign_batch_operation(placeholders, nil), do: placeholders

  defp assign_batch_operation(placeholders, batch_operation),
    do: Map.put(placeholders, :batch_operation_id, batch_operation && batch_operation.id)

  defp assign_document(placeholders, nil), do: placeholders

  defp assign_document(placeholders, document), do: Map.put(placeholders, :document_id, document && document.id)

  defp assign_revision(placeholders, nil), do: placeholders

  defp assign_revision(placeholders, revision), do: Map.put(placeholders, :revision_id, revision && revision.id)

  defp assign_version(placeholders, nil), do: placeholders

  defp assign_version(placeholders, version), do: Map.put(placeholders, :version_id, version && version.id)

  defp assign_options(operations, assigns) do
    options = Enum.flat_map(@options_keys, &Map.get(assigns, &1, []))

    %{operations | options: options}
  end
end
