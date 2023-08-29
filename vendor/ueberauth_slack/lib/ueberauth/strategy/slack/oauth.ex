defmodule Ueberauth.Strategy.Slack.OAuth do
  @moduledoc """
  An implementation of OAuth2 for Slack OAuth V2 API.
  To add your `client_id` and `client_secret` include these values in your configuration.
      config :ueberauth, Ueberauth.Strategy.Slack.OAuth,
        client_id: System.get_env("SLACK_CLIENT_ID"),
        client_secret: System.get_env("SLACK_CLIENT_SECRET")
  The JSON serializer used is the same as `Ueberauth` so if you need to
  customize it, you can configure it in the `Ueberauth` configuration:
      config :ueberauth, Ueberauth,
        json_library: Poison # Defaults to Jason
  """
  use OAuth2.Strategy

  @defaults [
    strategy: __MODULE__,
    site: "https://slack.com/api",
    authorize_url: "https://slack.com/oauth/v2/authorize",
    token_url: "https://slack.com/api/oauth.v2.access"
  ]

  def client(opts \\ []) do
    slack_config = Application.get_env(:ueberauth, Ueberauth.Strategy.Slack.OAuth)

    client_opts =
      @defaults
      |> Keyword.merge(slack_config)
      |> Keyword.merge(opts)

    json_library = Ueberauth.json_library()

    client_opts
    |> OAuth2.Client.new()
    |> OAuth2.Client.put_serializer("application/json", json_library)
  end

  def get(token, url, params \\ %{}, headers \\ [], opts \\ []) do
    url =
      [token: token]
      |> client()
      |> to_url(url, params)

    headers = [{"authorization", "Bearer #{token.access_token}"}] ++ headers
    OAuth2.Client.get(client(), url, headers, opts)
  end

  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  @doc """
  Returns two tokens from Slack API, a "bot token" and a "user token"
  """
  @spec get_token!(list(), map()) :: {%OAuth2.AccessToken{} | nil, %OAuth2.AccessToken{} | nil}
  def get_token!(params \\ [], options \\ %{}) do
    headers = Map.get(options, :headers, [])
    options = Map.get(options, :options, [])
    client_options = Keyword.get(options, :client_options, [])

    client = OAuth2.Client.get_token!(client(client_options), params, headers, options)

    split_token(client.token)
  end

  defp split_token(nil), do: {nil, nil}

  defp split_token(token) do
    {token, OAuth2.AccessToken.new(token.other_params["authed_user"])}
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param("client_secret", client.client_secret)
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end

  defp endpoint("/" <> _path = endpoint, client), do: client.site <> endpoint
  defp endpoint(endpoint, _client), do: endpoint

  defp to_url(client, endpoint, params) do
    client_endpoint =
      client
      |> Map.get(endpoint, endpoint)
      |> endpoint(client)

    final_endpoint =
      if params do
        client_endpoint <> "?" <> URI.encode_query(params)
      else
        client_endpoint
      end

    final_endpoint
  end
end
