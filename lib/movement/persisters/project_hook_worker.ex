defmodule Movement.Persisters.ProjectHookWorker do
  @moduledoc false
  use Oban.Worker, queue: :hook

  import Ecto.Query

  alias Accent.Hook
  alias Accent.Repo
  alias Accent.Scopes.Project, as: ProjectScope

  defmodule ProjectState do
    @moduledoc false
    @derive Jason.Encoder
    defstruct translations_count: 0, reviewed_count: 0, conflicts_count: 0

    @type t :: %__MODULE__{}
  end

  defmodule Args do
    @moduledoc false
    defstruct previous_project_state: %ProjectState{},
              operations_count: 0,
              project_id: nil,
              user_id: nil,
              batch_action: nil,
              batch_operation_stats: nil,
              document_path: nil

    @type t :: %__MODULE__{}
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    args = cast_args(args)
    current_project_state = get_project_state(args.project_id)

    for module <- Accent.Hook.Events.available() do
      if module.triggered?(args, current_project_state) do
        Hook.outbound(%Hook.Context{
          event: module.name(),
          project_id: args.project_id,
          user_id: args.user_id,
          payload: module.payload(args, current_project_state)
        })
      end
    end

    :ok
  end

  def get_project_state(nil), do: nil
  def get_project_state(%{id: id}), do: get_project_state(id)

  def get_project_state(project_id) do
    project =
      Accent.Project
      |> from(where: [id: ^project_id])
      |> ProjectScope.with_stats()
      |> Repo.one!()

    %ProjectState{
      translations_count: project.translations_count,
      reviewed_count: project.reviewed_count,
      conflicts_count: project.conflicts_count
    }
  end

  defp cast_args(args) do
    %Args{
      previous_project_state: cast_project_state(args["previous_project_state"]),
      project_id: args["project_id"],
      user_id: args["user_id"],
      operations_count: args["operations_count"],
      batch_action: args["batch_action"],
      batch_operation_stats: args["batch_operation_stats"],
      document_path: args["document_path"]
    }
  end

  defp cast_project_state(nil), do: nil

  defp cast_project_state(args) do
    %ProjectState{
      translations_count: args["translations_count"],
      reviewed_count: args["reviewed_count"],
      conflicts_count: args["conflicts_count"]
    }
  end
end
