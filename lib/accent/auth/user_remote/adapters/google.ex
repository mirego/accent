defmodule Accent.UserRemote.Adapters.Google do
  @moduledoc """
  Fetches the email and the uid from the id_token
  using the Google API v3 token info endpoint.
  """

  @behaviour Accent.UserRemote.Adapter.Fetcher
  @name "google"

  alias Accent.UserRemote.Adapter.User

  defmodule TokenInfoClient do
    use HTTPoison.Base

    @base_url "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token="

    def process_url(token), do: @base_url <> token

    def process_response_body(body), do: Jason.decode!(body)
  end

  def fetch(token) when token === "", do: {:error, "invalid token"}

  def fetch(token) do
    token
    |> TokenInfoClient.get()
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        email = String.downcase(body["email"])
        {:ok, %User{provider: @name, fullname: body["name"], picture_url: body["picture"], email: email, uid: email}}

      {:ok, %HTTPoison.Response{status_code: 400}} ->
        {:error, "invalid token"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
