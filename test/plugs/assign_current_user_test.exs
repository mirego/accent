defmodule AccentTest.Plugs.AssignCurrentUser do
  @moduledoc false
  use Accent.RepoCase, async: true
  use Plug.Test

  alias Accent.AccessToken
  alias Accent.Plugs.AssignCurrentUser
  alias Accent.Repo
  alias Accent.User

  @user %User{email: "test@test.com"}
  @token %AccessToken{revoked_at: nil, token: "1234"}

  defp call_plug(token) do
    :get
    |> conn("/foo")
    |> put_req_header("authorization", "Bearer #{token}")
    |> AssignCurrentUser.call(AssignCurrentUser.init([]))
  end

  test "assign current_user" do
    user =
      @user
      |> Repo.insert!()
      |> Map.put(:permissions, %{})

    token = Repo.insert!(Map.put(@token, :user_id, user.id))

    assigned_user =
      token.token
      |> call_plug()
      |> Map.get(:assigns)
      |> Map.get(:current_user)

    assert assigned_user.id == user.id
  end

  test "unknown current_user" do
    assigned_user =
      "123456789"
      |> call_plug()
      |> Map.get(:assigns)
      |> Map.get(:current_user)

    assert assigned_user == nil
  end
end
