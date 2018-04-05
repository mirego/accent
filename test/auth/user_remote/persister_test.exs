defmodule AccentTest.UserRemote.Persister do
  use Accent.RepoCase

  alias Accent.Repo
  alias Accent.User
  alias Accent.AuthProvider
  alias Accent.UserRemote.Persister
  alias Accent.UserRemote.Adapter.User, as: UserFromFetcher

  @user %UserFromFetcher{email: "test@test.com", provider: "google", uid: "1234"}

  test "persist with new user" do
    {:ok, user, provider} = Persister.persist(@user)

    assert user === Repo.get_by!(User, email: "test@test.com")
    assert provider === Repo.get_by!(AuthProvider, uid: "1234", name: "google", user_id: user.id)
  end

  test "persist with existing user existing provider" do
    existing_user = Repo.insert!(%User{email: @user.email})
    existing_provider = Repo.insert!(%AuthProvider{name: @user.provider, uid: @user.uid})

    {:ok, user, provider} = Persister.persist(@user)

    assert user === existing_user
    assert provider === existing_provider
  end

  test "persist with existing user new provider" do
    existing_user = Repo.insert!(%User{email: @user.email})
    Repo.insert!(%AuthProvider{name: "dummy", uid: @user.email})

    {:ok, user, provider} = Persister.persist(@user)

    assert user === existing_user
    assert provider === Repo.get_by!(AuthProvider, uid: "1234", name: "google", user_id: user.id)
  end
end
