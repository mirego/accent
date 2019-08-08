defmodule AccentTest.UserRemote.Persister do
  use Accent.RepoCase

  alias Accent.AuthProvider
  alias Accent.Repo
  alias Accent.User
  alias Accent.UserRemote.Persister
  alias Accent.UserRemote.User, as: UserFromFetcher

  @user %UserFromFetcher{email: "test@test.com", provider: "google", uid: "1234"}

  test "persist with new user" do
    user = Persister.persist(@user)

    assert user.id === Repo.get_by!(User, email: "test@test.com").id
    assert Repo.get_by!(AuthProvider, uid: "1234", name: "google", user_id: user.id)
  end

  test "persist with existing user existing provider" do
    existing_user = Repo.insert!(%User{email: @user.email})
    Repo.insert!(%AuthProvider{name: @user.provider, uid: @user.uid})

    user = Persister.persist(@user)

    assert user.id === existing_user.id
    assert length(Repo.all(AuthProvider)) === 1
  end

  test "persist with existing user new provider" do
    existing_user = Repo.insert!(%User{email: @user.email})
    Repo.insert!(%AuthProvider{name: "dummy", uid: @user.email})

    user = Persister.persist(@user)

    assert user.id === existing_user.id
    assert Repo.get_by!(AuthProvider, uid: "1234", name: "google", user_id: user.id)
  end
end
