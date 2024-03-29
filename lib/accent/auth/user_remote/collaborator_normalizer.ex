defmodule Accent.UserRemote.CollaboratorNormalizer do
  @moduledoc false
  import Ecto.Query, only: [from: 2]

  alias Accent.Collaborator
  alias Accent.Repo
  alias Accent.User

  @spec normalize(User.t()) :: User.t()
  def normalize(%User{id: id, email: email} = user) do
    email
    |> fetch_collaborators()
    |> assign_user_id(id)
    |> Enum.each(&Repo.update/1)

    user
  end

  defp fetch_collaborators(email) do
    email = String.downcase(email)

    Collaborator
    |> from(where: [email: ^email])
    |> Repo.all()
  end

  defp assign_user_id(collaborators, user_id) do
    Enum.map(collaborators, fn collaborator ->
      Collaborator.create_changeset(collaborator, %{"user_id" => user_id})
    end)
  end
end
