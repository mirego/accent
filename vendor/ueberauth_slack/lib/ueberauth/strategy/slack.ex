defmodule Ueberauth.Strategy.Slack do
  @moduledoc """
  Implements an ÜeberauthSlack strategy for authentication with Slack V2 OAuth API.

  When configuring the strategy in the Üeberauth providers, you can specify some defaults.

  * `uid_field` - The field to use as the UID field. This can be any populated field in the info struct. Default `:email`
  * `default_scope` - The scope to request by default from slack (permissions). Default "users:read"
  * `default_users_scope` - The scope to request by default from slack (permissions). Default "users:read"
  * `oauth2_module` - The OAuth2 module to use. Default Ueberauth.Strategy.Slack.OAuth

  ```elixir

  config :ueberauth, Ueberauth,
    providers: [
      slack: { Ueberauth.Strategy.Slack, [uid_field: :nickname, default_scope: "users:read,users:write"] }
    ]
  ```
  """
  use Ueberauth.Strategy,
    uid_field: :email,
    default_scope: "users:read",
    default_user_scope: "",
    oauth2_module: Ueberauth.Strategy.Slack.OAuth

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  # When handling the request just redirect to Slack
  @doc false
  def handle_request!(conn) do
    scopes = conn.params["scope"] || option(conn, :default_scope)
    user_scopes = conn.params["user_scope"] || option(conn, :default_user_scope)
    team = option(conn, :team)

    opts = [scope: scopes, user_scope: user_scopes]
    opts = with_state_param(opts, conn)
    opts = if team, do: Keyword.put(opts, :team, team), else: opts

    callback_url = callback_url(conn)

    callback_url =
      if String.ends_with?(callback_url, "?"),
        do: String.slice(callback_url, 0..-2//-1),
        else: callback_url

    opts = Keyword.put(opts, :redirect_uri, callback_url)
    module = option(conn, :oauth2_module)

    redirect!(conn, apply(module, :authorize_url!, [opts]))
  end

  # When handling the callback, if there was no errors we need to
  # make two calls. The first, to fetch the slack auth is so that we can get hold of
  # the user id so we can make a query to fetch the user info.
  # So that it is available later to build the auth struct, we put it in the private section of the conn.
  @doc false
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    module = option(conn, :oauth2_module)
    params = [code: code]
    redirect_uri = get_redirect_uri(conn)

    options = %{
      options: [
        client_options: [redirect_uri: redirect_uri]
      ]
    }

    case apply(module, :get_token!, [params, options]) do
      {%{access_token: nil}, %{access_token: nil} = user_token} ->
        set_errors!(conn, [
          error(user_token.other_params["error"], user_token.other_params["error_description"])
        ])

      {bot_token, %{access_token: nil}} ->
        handle_token(conn, bot_token)
        |> store_bot_token(bot_token)

      {bot_token, user_token} ->
        handle_token(conn, user_token)
        |> store_bot_token(bot_token)
    end
  end

  # If we don't match code, then we have an issue
  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  defp handle_token(conn, token) do
    conn
    |> store_token(token)
    |> fetch_auth(token)
    |> fetch_identity(token)
    |> fetch_user(token)
    |> fetch_team(token)
  end

  # We store the token for use later when fetching the slack auth and user and constructing the auth struct.
  @doc false
  defp store_token(conn, token) do
    put_private(conn, :slack_token, token)
  end

  defp store_bot_token(conn, token) do
    put_private(conn, :slack_bot_token, token)
  end

  # Remove the temporary storage in the conn for our data. Run after the auth struct has been built.
  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:slack_auth, nil)
    |> put_private(:slack_identity, nil)
    |> put_private(:slack_user, nil)
    |> put_private(:slack_token, nil)
    |> put_private(:slack_bot_token, nil)
  end

  # The structure of the requests is such that it is difficult to provide cusomization for the uid field.
  # instead, we allow selecting any field from the info struct
  @doc false
  def uid(conn) do
    Map.get(info(conn), option(conn, :uid_field))
  end

  @doc false
  def credentials(conn) do
    token = conn.private.slack_token
    bot_token = conn.private.slack_bot_token
    auth = conn.private[:slack_auth]
    identity = conn.private[:slack_identity]
    user = conn.private[:slack_user]
    scope_string = token.other_params["scope"] || ""
    scopes = String.split(scope_string, ",")

    %Credentials{
      token: token.access_token,
      refresh_token: token.refresh_token,
      expires_at: token.expires_at,
      token_type: token.token_type,
      expires: !!token.expires_at,
      scopes: scopes,
      other:
        Map.merge(
          %{
            user: get_in(auth, ["user"]),
            user_id: get_in(auth, ["user_id"]) || get_in(identity, ["user", "id"]),
            team: get_in(auth, ["team"]) || get_in(identity, ["team", "name"]),
            team_id: get_in(auth, ["team_id"]) || get_in(identity, ["team", "id"]),
            team_domain: get_in(identity, ["team", "domain"]),
            team_url: get_in(auth, ["url"]),
            bot_token: bot_token.access_token
          },
          user_credentials(user)
        )
    }
  end

  @doc false
  def info(conn) do
    user = conn.private[:slack_user]
    auth = conn.private[:slack_auth]
    identity = conn.private[:slack_identity]

    profile = get_in(user, ["profile"]) || get_in(identity, ["user"]) || %{}

    image_urls =
      profile
      |> Map.keys()
      |> Enum.filter(&(&1 =~ ~r/^image_/))
      |> Enum.into(%{}, &{&1, profile[&1]})

    team_image_urls =
      (identity || %{})
      |> Map.get("team", %{})
      |> Enum.filter(fn {key, _value} -> key =~ ~r/^image_/ end)
      |> Enum.into(%{}, fn {key, value} -> {"team_#{key}", value} end)

    %Info{
      name: name_from_user(user) || get_in(identity, ["user", "name"]),
      nickname: get_in(user, ["name"]),
      email: get_in(profile, ["email"]),
      image: get_in(profile, ["image_48"]),
      urls:
        image_urls
        |> Map.merge(team_image_urls)
        |> Map.merge(%{
          team_url: get_in(auth, ["url"])
        })
    }
  end

  @doc false
  def extra(conn) do
    %Extra{
      raw_info: %{
        auth: conn.private[:slack_auth],
        identity: conn.private[:slack_identity],
        token: conn.private[:slack_token],
        bot_token: conn.private[:slack_bot_token],
        user: conn.private[:slack_user],
        team: conn.private[:slack_team]
      }
    }
  end

  defp user_credentials(nil), do: %{}

  defp user_credentials(user) do
    %{
      has_2fa: user["has_2fa"],
      is_admin: user["is_admin"],
      is_owner: user["is_owner"],
      is_primary_owner: user["is_primary_owner"],
      is_restricted: user["is_restricted"],
      is_ultra_restricted: user["is_ultra_restricted"]
    }
  end

  # Before we can fetch the user, we first need to fetch the auth to find out what the user id is.
  defp fetch_auth(conn, token) do
    scope_string = token.other_params["scope"] || ""
    scopes = String.split(scope_string, ",")

    case Ueberauth.Strategy.Slack.OAuth.get(token, "/auth.test") do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])

      {:ok, %OAuth2.Response{status_code: status_code, body: auth}}
      when status_code in 200..399 ->
        cond do
          auth["ok"] ->
            put_private(conn, :slack_auth, auth)

          auth["error"] == "invalid_auth" && Enum.member?(scopes, "identity.basic") ->
            # If the token has only the "identity.basic" scope then it may error
            # at the "auth.test" endpoint but still succeed at the
            # "identity.basic" endpoint.
            # In this case we rely on fetch_identity to set the error if the
            # token is invalid.
            conn

          true ->
            set_errors!(conn, [error(auth["error"], auth["error"])])
        end

      {:error, %OAuth2.Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end

  defp fetch_identity(conn, token) do
    scope_string = token.other_params["scope"] || ""
    scopes = String.split(scope_string, ",")

    case "identity.basic" in scopes do
      false ->
        conn

      true ->
        case Ueberauth.Strategy.Slack.OAuth.get(token, "/users.identity") do
          {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
            set_errors!(conn, [error("token", "unauthorized")])

          {:ok, %OAuth2.Response{status_code: status_code, body: identity}}
          when status_code in 200..399 ->
            if identity["ok"] do
              put_private(conn, :slack_identity, identity)
            else
              set_errors!(conn, [error(identity["error"], identity["error"])])
            end

          {:error, %OAuth2.Error{reason: reason}} ->
            set_errors!(conn, [error("OAuth2", reason)])
        end
    end
  end

  # If the call to fetch the auth fails, we're going to have failures already in place.
  # If this happens don't try and fetch the user and just let it fail.
  defp fetch_user(%Plug.Conn{assigns: %{ueberauth_failure: _fails}} = conn, _), do: conn

  # Given the auth and token we can now fetch the user.
  defp fetch_user(conn, token) do
    scope_string = token.other_params["scope"] || ""
    scopes = String.split(scope_string, ",")

    case "users:read" in scopes do
      false ->
        conn

      true ->
        auth = conn.private.slack_auth

        case Ueberauth.Strategy.Slack.OAuth.get(token, "/users.info", %{user: auth["user_id"]}) do
          {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
            set_errors!(conn, [error("token", "unauthorized")])

          {:ok, %OAuth2.Response{status_code: status_code, body: user}}
          when status_code in 200..399 ->
            if user["ok"] do
              put_private(conn, :slack_user, user["user"])
            else
              set_errors!(conn, [error(user["error"], user["error"])])
            end

          {:error, %OAuth2.Error{reason: reason}} ->
            set_errors!(conn, [error("OAuth2", reason)])
        end
    end
  end

  defp fetch_team(%Plug.Conn{assigns: %{ueberauth_failure: _fails}} = conn, _), do: conn

  defp fetch_team(conn, token) do
    scope_string = token.other_params["scope"] || ""
    scopes = String.split(scope_string, ",")

    case "team:read" in scopes do
      false ->
        conn

      true ->
        case Ueberauth.Strategy.Slack.OAuth.get(token, "/team.info") do
          {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
            set_errors!(conn, [error("token", "unauthorized")])

          {:ok, %OAuth2.Response{status_code: status_code, body: team}}
          when status_code in 200..399 ->
            if team["ok"] do
              put_private(conn, :slack_team, team["team"])
            else
              set_errors!(conn, [error(team["error"], team["error"])])
            end

          {:error, %OAuth2.Error{reason: reason}} ->
            set_errors!(conn, [error("OAuth2", reason)])
        end
    end
  end

  # Fetch the name to use. We try to start with the most specific name avaialble and
  # fallback to the least.
  defp name_from_user(nil), do: nil

  defp name_from_user(user) do
    [
      user["profile"]["real_name_normalized"],
      user["profile"]["real_name"],
      user["real_name"],
      user["name"]
    ]
    |> Enum.reject(&(&1 == "" || &1 == nil))
    |> List.first()
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end

  defp get_redirect_uri(%Plug.Conn{} = conn) do
    config = Application.get_env(:ueberauth, Ueberauth)
    redirect_uri = Keyword.get(config, :redirect_uri)

    if is_nil(redirect_uri) do
      callback_url(conn)
    else
      redirect_uri
    end
  end
end
