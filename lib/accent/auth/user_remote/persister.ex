defmodule Accent.UserRemote.Persister do
  @moduledoc """
  Manage user creation and provider creation.

  This module makes sure that a user, returned from the Accent.UserRemote.Fetcher,
  is persisted in the database with its provider infos and email.

  3 cases can happen when a user is fetched.

  - New user with new provider. (First time logging in)
  - Existing user with same provider. (Same login as the first time)
  - Existing user but with a different provider. (Login with a different provider)

  """
  alias Accent.AuthProvider
  alias Accent.Repo
  alias Accent.User, as: RepoUser
  alias Accent.UserRemote.User, as: FetchedUser
  alias Ecto.Changeset

  @spec persist(FetchedUser.t()) :: RepoUser.t()
  def persist(user = %FetchedUser{provider: provider, uid: uid}) do
    user
    |> find_or_create_user()
    |> find_or_create_provider(provider, uid)
  end

  defp find_or_create_user(fetched_user) do
    case Repo.get_by(RepoUser, email: fetched_user.email) do
      nil -> create_user(fetched_user)
      user -> update_user(user, fetched_user)
    end
  end

  defp find_or_create_provider(user, provider_name, uid) do
    case Repo.get_by(AuthProvider, name: provider_name, uid: uid) do
      nil ->
        create_provider(user, provider_name, uid)
        user

      _ ->
        user
    end
  end

  defp create_provider(user, name, uid), do: Repo.insert!(%AuthProvider{name: name, uid: uid, user_id: user.id})
  defp create_user(fetched_user), do: Repo.insert!(%RepoUser{email: fetched_user.email, fullname: fetched_user.fullname, picture_url: fetched_user.picture_url})

  defp update_user(user, fetched_user) do
    user
    |> Changeset.change(%{
      fullname: fetched_user.fullname || user.fullname,
      picture_url: fetched_user.picture_url || user.picture_url
    })
    |> Repo.update!()
  end
end
