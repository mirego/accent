defmodule Accent.CollaboratorUpdater do
  @moduledoc false
  alias Accent.Collaborator
  alias Accent.Repo

  def update(collaborator, params) do
    collaborator
    |> Collaborator.update_changeset(params)
    |> Repo.update()
  end
end
