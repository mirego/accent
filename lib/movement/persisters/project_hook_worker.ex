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
              project: nil,
              document: nil,
              master_revision: nil,
              revision: nil,
              version: nil,
              batch_operation: nil,
              batch_action: nil,
              user: nil

    @type t :: %__MODULE__{}
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    args = cast_args(args)
    current_project_state = get_project_state(args.project)

    for module <- Accent.Hook.Events.available() do
      if module.triggered?(args, current_project_state) do
        Hook.outbound(%Hook.Context{
          event: module.name(),
          project_id: args.project.id,
          user_id: args.user && args.user.id,
          payload: module.payload(args, current_project_state)
        })
      end
    end

    :ok
  end

  def get_project_state(nil), do: nil

  def get_project_state(project) do
    project =
      Accent.Project
      |> from(where: [id: ^project.id])
      |> ProjectScope.with_stats()
      |> Repo.one()

    struct!(ProjectState, Map.take(project, ~w(translations_count reviewed_count conflicts_count)a))
  end

  defp cast_args(args) do
    %Args{
      previous_project_state: cast_project_state(args["previous_project_state"]),
      project: get_record(Accent.Project, args["project_id"]),
      document: get_record(Accent.Document, args["document_id"]),
      master_revision: get_record(Accent.Revision, args["master_revision_id"]),
      revision: get_record(Accent.Revision, args["revision_id"]),
      version: get_record(Accent.Version, args["version_id"]),
      batch_operation: get_record(Accent.Operation, args["batch_operation_id"]),
      operations_count: args["operations_count"],
      batch_action: args["batch_action"],
      user: get_record(Accent.User, args["user_id"])
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

  defp get_record(_schema, nil), do: nil
  defp get_record(schema, id), do: Repo.get(schema, id)
end
