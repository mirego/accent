defmodule Movement.Persisters.ProjectStateChangeWorker do
  use Oban.Worker, queue: :hook

  import Ecto.Query

  alias Accent.Hook
  alias Accent.Repo
  alias Accent.Scopes.Project, as: ProjectScope

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    args = cast_args(args)
    current_project_state = get_project_state(args.project)

    if new_conflicts_to_review?(args.previous_project_state, current_project_state) do
      Hook.outbound(%Hook.Context{
        event: "new_conflicts",
        project_id: args.project.id,
        user_id: args.user.id,
        payload: %{
          reviewed_count: current_project_state.project.reviewed_count,
          translations_count: current_project_state.project.translations_count,
          new_conflicts_count: current_project_state.project.conflicts_count - args.previous_project_state.project.conflicts_count
        }
      })
    end

    if all_reviewed?(args.previous_project_state, current_project_state) do
      Hook.outbound(%Hook.Context{
        event: "complete_review",
        project_id: args.project.id,
        user_id: args.user.id,
        payload: %{
          translations_count: current_project_state.project.translations_count
        }
      })
    end

    :ok
  end

  defp new_conflicts_to_review?(previous_state, current_state) do
    previous_state.project.conflicts_count < current_state.project.conflicts_count
  end

  defp all_reviewed?(previous_state, current_state) do
    previous_state.project.reviewed_count !== previous_state.project.translations_count and
      current_state.project.reviewed_count === current_state.project.translations_count
  end

  def get_project_state(nil), do: nil

  def get_project_state(project) do
    project =
      Accent.Project
      |> from(where: [id: ^project.id])
      |> ProjectScope.with_stats()
      |> Repo.one()

    %{project: Map.take(project, ~w(translations_count reviewed_count conflicts_count)a)}
  end

  defp cast_project_state(args) do
    %{
      project: %{
        translations_count: args["project"]["translations_count"],
        reviewed_count: args["project"]["reviewed_count"],
        conflicts_count: args["project"]["conflicts_count"]
      }
    }
  end

  defp cast_args(args) do
    %{
      previous_project_state: cast_project_state(args["previous_project_state"]),
      project: get_record(Accent.Project, args["project_id"]),
      document: get_record(Accent.Document, args["document_id"]),
      master_revision: get_record(Accent.Revision, args["master_revision_id"]),
      revision: get_record(Accent.Revision, args["revision_id"]),
      version: get_record(Accent.Version, args["version_id"]),
      batch_operation: get_record(Accent.Operation, args["batch_operation_id"]),
      user: get_record(Accent.User, args["user_id"])
    }
  end

  defp get_record(_schema, nil), do: nil
  defp get_record(schema, id), do: Repo.get(schema, id)
end
