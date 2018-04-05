defmodule Accent.CollaboratorUpdater do
  alias Accent.{Repo, Collaborator}

  def update(collaborator, params) do
    collaborator
    |> Collaborator.update_changeset(params)
    |> Repo.update()
  end
end
