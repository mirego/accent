defmodule AccentTest.UserRemote.TokenGiver do
  @moduledoc false
  use Accent.RepoCase

  alias Accent.AccessToken
  alias Accent.Repo
  alias Accent.User
  alias Accent.UserRemote.TokenGiver

  @user %User{email: "test@test.com"}
  @token %AccessToken{revoked_at: nil, token: "1234"}

  test "revoke existing token" do
    user = Repo.insert!(@user)
    token = Repo.insert!(Map.merge(@token, %{user_id: user.id}))

    TokenGiver.grant_token(user)

    revoked_token = Repo.get_by!(AccessToken, token: token.token)

    assert revoked_token.revoked_at !== nil
  end

  test "create token" do
    user = Repo.insert!(@user)

    TokenGiver.grant_token(user)

    new_token = Repo.get_by!(AccessToken, user_id: user.id)

    assert new_token !== nil
  end
end
