defmodule Accent.CollaboratorCreator do
  alias Accent.{Collaborator, Repo, User}

  def create(params) do
    %Collaborator{}
    |> Collaborator.create_changeset(params)
    |> assign_user
    |> Repo.insert()
  end

  defp assign_user(collaborator) do
    case fetch_user(collaborator.changes[:email]) do
      %User{id: id} -> Ecto.Changeset.put_change(collaborator, :user_id, id)
      nil -> collaborator
    end
  end

  defp fetch_user(email) do
    Repo.get_by(User, email: email)
  end
end
