defmodule Accent.Hook.Events.AddTranslations do
  @moduledoc false
  @behaviour Accent.Hook.Event

  alias Movement.Persisters.ProjectHookWorker

  @impl true
  def name do
    "add_translations"
  end

  @impl true
  def triggered?(%ProjectHookWorker.Args{} = args, _new_state) do
    args.batch_action === "merge" and args.operations_count > 0
  end

  @impl true
  def payload(%ProjectHookWorker.Args{} = args, _new_state) do
    %{
      language_name: args.revision.language.name
    }
  end
end
