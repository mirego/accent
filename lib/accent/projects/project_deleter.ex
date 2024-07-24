defmodule Accent.ProjectDeleter do
  @moduledoc false
  import Ecto.Query, only: [from: 2]

  alias Accent.Operation
  alias Accent.Repo

  def delete(project: project) do
    project
    |> Ecto.assoc(:all_collaborators)
    |> Repo.delete_all()

    Repo.transaction(fn ->
      Repo.delete_all(
        from(operations in Operation,
          inner_join: revisions in assoc(operations, :revision),
          where: revisions.project_id == ^project.id
        )
      )

      Repo.delete_all(from(operations in Operation, where: operations.project_id == ^project.id))
    end)

    {:ok, project}
  end
end
