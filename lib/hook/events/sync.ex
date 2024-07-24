defmodule Accent.Hook.Events.Sync do
  @moduledoc false
  @behaviour Accent.Hook.Event

  alias Movement.Persisters.ProjectHookWorker

  @impl true
  def name do
    "sync"
  end

  @impl true
  def triggered?(%ProjectHookWorker.Args{} = args, _new_state) do
    args.batch_action === "sync" and args.operations_count > 0
  end

  @impl true
  def payload(%ProjectHookWorker.Args{} = args, _new_state) do
    %{
      batch_operation_stats: args.batch_operation.stats,
      document_path: args.document.path
    }
  end
end
