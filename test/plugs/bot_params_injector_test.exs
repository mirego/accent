defmodule AccentTest.Plugs.BotParamsInjector do
  @moduledoc false
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn

  alias Accent.Plugs.BotParamsInjector
  alias Accent.User

  defp call_plug(user, query_params \\ %{}) do
    :get
    |> conn("/foo", query_params)
    |> assign(:current_user, user)
    |> Plug.Conn.fetch_query_params()
    |> BotParamsInjector.call(BotParamsInjector.init([]))
  end

  test "add project id param when user is bot" do
    project_id =
      %User{email: "bot", bot: true, permissions: %{"1234" => "bot"}}
      |> call_plug()
      |> Map.get(:params)
      |> Map.get("project_id")

    assert project_id == "1234"
  end

  test "add project id variables absinthe param when user is bot" do
    project_id =
      %User{email: "bot", bot: true, permissions: %{"1234" => "bot"}}
      |> call_plug()
      |> Map.get(:params)
      |> Map.get("variables")
      |> Map.get("project_id")

    assert project_id == "1234"
  end

  test "add project id variables absinthe param when user is bot and variables ar present" do
    project_id =
      %User{email: "bot", bot: true, permissions: %{"1234" => "bot"}}
      |> call_plug(%{"variables" => %{foo: "bar"}})
      |> Map.get(:params)
      |> Map.get("variables")
      |> Map.get("project_id")

    assert project_id == "1234"
  end

  test "unknown project id param when user is bot" do
    updated_conn = call_plug(%User{email: "bot", bot: true, permissions: %{}})

    assert updated_conn.state == :sent
    assert updated_conn.status == 401
    assert updated_conn.resp_body == "Unauthorized"
  end

  test "user is not bot" do
    updated_conn = call_plug(%User{email: "not-a-bot@example.com", bot: false, permissions: %{}})

    assert updated_conn.state == :unset
  end
end
