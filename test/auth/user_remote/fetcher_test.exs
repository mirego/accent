defmodule AccentTest.UserRemote.Fetcher do
  use Accent.RepoCase, async: false

  import Mock

  alias Accent.UserRemote.Adapter.User
  alias Accent.UserRemote.Fetcher

  defp mock_response(status, body) do
    %HTTPoison.Response{status_code: status, body: body}
  end

  test "google" do
    response = [request: fn _, _, _, _, _, _, _, _, _ -> {:ok, mock_response(200, %{"email" => "test@example.com", "name" => "Test"})} end]

    with_mock HTTPoison.Base, response do
      expected_user = %User{email: "test@example.com", fullname: "Test", picture_url: nil, provider: "google", uid: "test@example.com"}
      assert Fetcher.fetch("google", "test") == {:ok, expected_user}
    end
  end

  test "dummy" do
    expected_user = %User{email: "test@example.com", provider: "dummy", uid: "test@example.com"}
    assert Fetcher.fetch("dummy", "test@example.com") == {:ok, expected_user}
  end

  test "nil token" do
    assert Fetcher.fetch("dummy", nil) == {:error, %{value: "empty"}}
  end

  test "empty token" do
    assert Fetcher.fetch("dummy", "") == {:error, %{value: "empty"}}
  end

  test "unknown provider" do
    assert Fetcher.fetch("foo", "test") == {:error, %{provider: "unknown"}}
  end
end
