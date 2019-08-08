defmodule Accent.UserAuthFetcher do
  import Ecto.Query, only: [from: 2]

  alias Accent.{
    Collaborator,
    Repo,
    User
  }

  @doc """
  fetch the associated user. It also fetches the permissions
  """
  @spec fetch(String.t() | nil) :: User.t() | nil
  def fetch(access_token) do
    access_token
    |> fetch_user
    |> map_permissions
  end

  defp fetch_user("Bearer " <> token) when is_binary(token) do
    from(
      user in User,
      inner_join: access_token in assoc(user, :access_tokens),
      where: access_token.token == ^token,
      where: is_nil(access_token.revoked_at)
    )
    |> Repo.one()
  end

  defp fetch_user(_any), do: nil

  defp map_permissions(nil), do: nil

  defp map_permissions(user) do
    permissions =
      from(
        collaborator in Collaborator,
        where: [user_id: ^user.id],
        select: {collaborator.project_id, collaborator.role}
      )
      |> Repo.all()
      |> Enum.into(%{})

    %{user | permissions: permissions}
  end
end
