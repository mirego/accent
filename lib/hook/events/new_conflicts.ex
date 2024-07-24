defmodule Accent.Hook.Events.NewConflicts do
  @moduledoc false
  @behaviour Accent.Hook.Event

  alias Movement.Persisters.ProjectHookWorker

  @impl true
  def name do
    "new_conflicts"
  end

  @impl true
  def triggered?(%ProjectHookWorker.Args{} = args, %ProjectHookWorker.ProjectState{} = project_state) do
    args.previous_project_state.conflicts_count < project_state.conflicts_count
  end

  @impl true
  def payload(%ProjectHookWorker.Args{} = args, %ProjectHookWorker.ProjectState{} = project_state) do
    %{
      reviewed_count: project_state.reviewed_count,
      translations_count: project_state.translations_count,
      new_conflicts_count: project_state.conflicts_count - args.previous_project_state.conflicts_count
    }
  end
end
