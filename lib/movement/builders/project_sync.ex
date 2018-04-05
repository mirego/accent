defmodule Movement.Builders.ProjectSync do
  @behaviour Movement.Builder

  import Movement.Context, only: [assign: 3]

  alias Movement.Builders.RevisionSync, as: RevisionSyncBuilder
  alias Movement.Builders.SlaveConflictSync, as: SlaveConflictSyncBuilder

  alias Accent.Scopes.Revision, as: RevisionScope

  alias Accent.{Repo, Revision}

  def build(context) do
    # Don’t keep track of the last used revision to prevent error on further steps
    context
    |> Map.put(:operations, [])
    |> generate_operations
    |> assign(:revision, nil)
  end

  defp generate_operations(context = %Movement.Context{assigns: assigns}) do
    master_revision =
      Revision
      |> RevisionScope.from_project(assigns[:project].id)
      |> RevisionScope.master()
      |> Repo.one!()
      |> Repo.preload(:language)

    slave_revisions =
      Revision
      |> RevisionScope.from_project(assigns[:project].id)
      |> RevisionScope.slaves()
      |> Repo.all()
      |> Repo.preload(:language)

    context
    |> assign(:master_revision, master_revision)
    |> assign(:slave_revisions, slave_revisions)
    |> assign_revisions_operations
  end

  defp assign_revisions_operations(context) do
    # Master revision
    # Slave revisions conflicts
    context =
      context
      |> assign(:revision, context.assigns[:master_revision])
      |> RevisionSyncBuilder.build()
      |> assign(:revisions, context.assigns[:slave_revisions])
      |> SlaveConflictSyncBuilder.build()

    # Slave revisions add/remove
    Enum.reduce(context.assigns[:slave_revisions], context, fn revision, acc ->
      acc
      |> assign(:revision, revision)
      |> RevisionSyncBuilder.build()
    end)
  end
end
