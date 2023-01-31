defmodule Accent.APITokenManager do
  alias Accent.RoleAbilities
  alias Accent.{AccessToken, Collaborator, Repo}
  alias Ecto.Multi

  import Ecto.Changeset
  import Ecto.Query

  def create(project, user, params) do
    params = %{
      "custom_permissions" => params[:permissions],
      "user" => %{
        "fullname" => params[:name],
        "picture_url" => params[:picture_url]
      }
    }

    changeset =
      %AccessToken{
        token: Accent.Utils.SecureRandom.urlsafe_base64(70)
      }
      |> cast(params, [:custom_permissions])
      |> validate_subset(:custom_permissions, Enum.map(RoleAbilities.actions_for(:all), &to_string/1))
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
    Repo.delete_all(from(AccessToken, where: [id: ^access_token.id]))
    :ok
  end

  def list(project) do
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
  end
end
