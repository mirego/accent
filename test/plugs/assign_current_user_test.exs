defmodule AccentTest.Plugs.AssignCurrentUser do
  @moduledoc false
  use Accent.RepoCase, async: true
  use Plug.Test

  alias Accent.AccessToken
  alias Accent.Plugs.AssignCurrentUser
  alias Accent.User

  defp call_plug(token) do
    :get
    |> conn("/foo")
    |> Plug.Test.init_test_session([])
    |> put_req_header("authorization", "Bearer #{token}")
    |> AssignCurrentUser.call(AssignCurrentUser.init([]))
  end

  test "assign current_user" do
    user =
      User
      |> Factory.insert()
      |> Map.put(:permissions, %{})

    token = Factory.insert(AccessToken, user_id: user.id)

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
