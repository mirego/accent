defmodule Movement.Builders.ProjectSync do
  @moduledoc false
  @behaviour Movement.Builder

  import Movement.Context, only: [assign: 3]

  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Scopes.Revision, as: RevisionScope
  alias Movement.Builders.RevisionSync, as: RevisionSyncBuilder
  alias Movement.Builders.SlaveConflictSync, as: SlaveConflictSyncBuilder

  @batch_action "sync"

  def build(context) do
    # Don’t keep track of the last used revision to prevent error on further steps
    context
    |> Map.put(:operations, [])
    |> assign(:batch_action, @batch_action)
    |> generate_operations()
    |> assign(:revision, nil)
  end

  defp generate_operations(%Movement.Context{assigns: assigns} = context) do
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
    |> assign_revisions_operations()
  end

  defp assign_revisions_operations(context) do
    context =
      context
      |> assign(:master_revision, context.assigns[:master_revision])
      |> assign(:revision, context.assigns[:master_revision])
      |> RevisionSyncBuilder.build()
      |> assign(:revisions, context.assigns[:slave_revisions])
      |> SlaveConflictSyncBuilder.build()

    Enum.reduce(context.assigns[:slave_revisions], context, fn revision, acc ->
      acc
      |> assign(:revision, revision)
      |> RevisionSyncBuilder.build()
    end)
  end
end
