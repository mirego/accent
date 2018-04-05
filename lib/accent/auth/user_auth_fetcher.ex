defmodule Accent.UserAuthFetcher do
  import Ecto.Query, only: [from: 2]

  alias Accent.{
    Repo,
    Collaborator,
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
      left_join: access_token in assoc(user, :access_tokens),
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
        select: %{project_id: collaborator.project_id, role: collaborator.role}
      )
      |> Repo.all()
      |> Enum.reduce(Map.new(), fn %{project_id: project_id, role: role}, acc ->
        Map.put(acc, project_id, role)
      end)

    user
    |> Map.put(:permissions, permissions)
  end
end
