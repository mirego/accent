defmodule AccentTest.UserRemote.Adapters.Google do
  use Accent.RepoCase, async: false

  import Mock

  alias Accent.UserRemote.Adapter.User
  alias Accent.UserRemote.Adapters.Google

  defp mock_response(status, body) do
    %HTTPoison.Response{status_code: status, body: body}
  end

  test "valid" do
    response = [request: fn _, _, _, _, _, _, _, _, _ -> {:ok, mock_response(200, %{"email" => "test@example.com", "name" => "Test"})} end]

    with_mock HTTPoison.Base, response do
      expected_user = %User{email: "test@example.com", fullname: "Test", picture_url: nil, provider: "google", uid: "test@example.com"}
      assert Google.fetch("test") == {:ok, expected_user}
    end
  end

  test "valid with picture" do
    response = [request: fn _, _, _, _, _, _, _, _, _ -> {:ok, mock_response(200, %{"email" => "test@example.com", "name" => "Test", "picture" => "test.jpg"})} end]

    with_mock HTTPoison.Base, response do
      expected_user = %User{email: "test@example.com", fullname: "Test", picture_url: "test.jpg", provider: "google", uid: "test@example.com"}
      assert Google.fetch("test") == {:ok, expected_user}
    end
  end

  test "valid with uppercase email" do
    response = [request: fn _, _, _, _, _, _, _, _, _ -> {:ok, mock_response(200, %{"email" => "TEST@example.com", "name" => "Test"})} end]

    with_mock HTTPoison.Base, response do
      expected_user = %User{email: "test@example.com", fullname: "Test", picture_url: nil, provider: "google", uid: "test@example.com"}
      assert Google.fetch("test") == {:ok, expected_user}
    end
  end

  test "invalid with status" do
    response = [request: fn _, _, _, _, _, _, _, _, _ -> {:ok, mock_response(400, %{})} end]

    with_mock HTTPoison.Base, response do
      assert Google.fetch("test") == {:error, "invalid token"}
    end
  end

  test "error" do
    response = [request: fn _, _, _, _, _, _, _, _, _ -> {:error, %HTTPoison.Error{reason: "no internet"}} end]

    with_mock HTTPoison.Base, response do
      assert Google.fetch("test") == {:error, "no internet"}
    end
  end
end
