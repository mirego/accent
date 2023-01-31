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
    |> fetch_user()
    |> map_permissions()
  end

  defp fetch_user("Bearer " <> token) when is_binary(token) do
    from(
      user in User,
      inner_join: access_token in assoc(user, :access_tokens),
      left_join: collaboration in assoc(user, :bot_collaborations),
      where: access_token.token == ^token,
      where: is_nil(access_token.revoked_at),
      select: {user, access_token.custom_permissions, collaboration}
    )
    |> Repo.one()
  end

  defp fetch_user(_any), do: nil

  defp map_permissions({user, [_ | _] = permissions, %{project_id: id}}) do
    %{user | permissions: %{id => {:custom, permissions}}}
  end

  defp map_permissions({user, _, _}) do
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

  defp map_permissions(nil), do: nil
end
