defmodule Accent.UserAuthFetcher do
  @moduledoc false
  import Ecto.Query, only: [from: 2]

  alias Accent.Collaborator
  alias Accent.Repo
  alias Accent.User

  @doc """
  fetch the associated user. It also fetches the permissions
  """
  @spec fetch(String.t() | nil) :: User.t() | nil
  def fetch(access_token) do
    access_token
    |> fetch_user()
    |> map_permissions()
  end

  @doc """
  fetch the associated user by id. It also fetches the permissions
  """
  @spec fetch_by_id(String.t() | nil) :: User.t() | nil
  def fetch_by_id(id) do
    id
    |> fetch_user_by_id()
    |> map_permissions()
  end

  defp fetch_user("Bearer " <> token) when is_binary(token) do
    result =
      Repo.one(
        from(user in User,
          inner_join: access_token in assoc(user, :access_tokens),
          left_join: collaboration in assoc(user, :bot_collaborations),
          where: access_token.token == ^token,
          where: is_nil(access_token.revoked_at),
          select: {user, access_token.id, access_token.custom_permissions, collaboration}
        )
      )

    case result do
      {user, access_token_id, custom_permissions, collaboration} ->
        Accent.AccessTokenUsageWriter.track_usage(access_token_id)
        {user, custom_permissions, collaboration}

      nil ->
        nil
    end
  end

  defp fetch_user(_any), do: nil

  defp fetch_user_by_id(id) when is_binary(id) do
    Repo.one(from(user in User, where: user.id == ^id, select: {user, [], nil}))
  end

  defp fetch_user_by_id(_any), do: nil

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
      |> Map.new()

    %{user | permissions: permissions}
  end

  defp map_permissions(nil), do: nil
end
