defmodule Accent.APITokenManager do
  @moduledoc false
  import Ecto.Changeset
  import Ecto.Query

  alias Accent.AccessToken
  alias Accent.Collaborator
  alias Accent.Repo
  alias Accent.RoleAbilities
  alias Ecto.Multi

  def create(project, user, params) do
    params = %{
      "custom_permissions" => params[:permissions],
      "user" => %{
        "fullname" => params[:name],
        "picture_url" => params[:picture_url]
      }
    }

    project_role = Map.get(user.permissions, project.id)
    permissions = Enum.map(RoleAbilities.actions_for(project_role, project), &to_string/1)

    changeset =
      %AccessToken{
        token: Accent.Utils.SecureRandom.urlsafe_base64(70)
      }
      |> cast(params, [:custom_permissions])
      |> validate_subset(:custom_permissions, permissions)
      |> cast_assoc(:user,
        with: fn changeset, params ->
          changeset
          |> cast(params, [:fullname, :picture_url])
          |> put_change(:bot, true)
        end
      )

    Multi.new()
    |> Multi.insert(:access_token, changeset)
    |> Multi.insert(:collaborator, fn %{access_token: access_token} ->
      %Collaborator{user_id: access_token.user_id, role: "bot", assigner_id: user.id, project_id: project.id}
    end)
    |> Repo.transaction()
  end

  def revoke(access_token) do
    Repo.transaction(fn ->
      access_token = if Ecto.assoc_loaded?(access_token.user), do: access_token, else: Repo.preload(access_token, :user)
      Repo.delete_all(from(AccessToken, where: [id: ^access_token.id]))

      if access_token.user && access_token.user.bot == true do
        Repo.delete_all(from(Collaborator, where: [user_id: ^access_token.user.id]))
        Repo.delete(access_token.user)
      end
    end)

    :ok
  end

  def list(project, user) do
    tokens =
      Repo.all(
        from(
          access_token in AccessToken,
          inner_join: user in assoc(access_token, :user),
          inner_join: collaboration in assoc(user, :collaborations),
          where: collaboration.project_id == ^project.id,
          where: user.bot == true,
          where: is_nil(access_token.revoked_at)
        )
      )

    project_role = Map.get(user.permissions, project.id)
    permissions = Enum.map(RoleAbilities.actions_for(project_role, project), &to_string/1)

    Enum.filter(tokens, fn token ->
      is_nil(token.custom_permissions) or
        Enum.all?(token.custom_permissions, fn permission ->
          permission in permissions
        end)
    end)
  end
end
