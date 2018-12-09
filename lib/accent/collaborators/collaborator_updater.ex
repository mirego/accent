defmodule Accent.CollaboratorUpdater do
  alias Accent.{Collaborator, Repo}

  def update(collaborator, params) do
    collaborator
    |> Collaborator.update_changeset(params)
    |> Repo.update()
  end
end
