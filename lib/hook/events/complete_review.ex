defmodule Accent.Hook.Events.CompleteReview do
  @moduledoc false
  @behaviour Accent.Hook.Event

  alias Movement.Persisters.ProjectHookWorker

  @impl true
  def name do
    "complete_review"
  end

  @impl true
  def triggered?(%ProjectHookWorker.Args{} = args, %ProjectHookWorker.ProjectState{} = project_state) do
    args.previous_project_state.reviewed_count !== args.previous_project_state.translations_count and
      project_state.reviewed_count === project_state.translations_count
  end

  @impl true
  def payload(_args, %ProjectHookWorker.ProjectState{} = project_state) do
    %{
      translations_count: project_state.translations_count
    }
  end
end
