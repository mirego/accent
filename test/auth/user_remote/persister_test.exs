defmodule AccentTest.UserRemote.Persister do
  use Accent.RepoCase

  alias Accent.AuthProvider
  alias Accent.Repo
  alias Accent.User
  alias Accent.UserRemote.Adapter.User, as: UserFromFetcher
  alias Accent.UserRemote.Persister

  @user %UserFromFetcher{email: "test@test.com", provider: "google", uid: "1234"}

  test "persist with new user" do
    {:ok, user, provider} = Persister.persist(@user)

    assert user.id === Repo.get_by!(User, email: "test@test.com").id
    assert provider.id === Repo.get_by!(AuthProvider, uid: "1234", name: "google", user_id: user.id).id
  end

  test "persist with existing user existing provider" do
    existing_user = Repo.insert!(%User{email: @user.email})
    existing_provider = Repo.insert!(%AuthProvider{name: @user.provider, uid: @user.uid})

    {:ok, user, provider} = Persister.persist(@user)

    assert user.id === existing_user.id
    assert provider.id === existing_provider.id
  end

  test "persist with existing user new provider" do
    existing_user = Repo.insert!(%User{email: @user.email})
    Repo.insert!(%AuthProvider{name: "dummy", uid: @user.email})

    {:ok, user, provider} = Persister.persist(@user)

    assert user.id === existing_user.id
    assert provider.id === Repo.get_by!(AuthProvider, uid: "1234", name: "google", user_id: user.id).id
  end
end
