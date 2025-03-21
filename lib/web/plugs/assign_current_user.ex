defmodule Accent.Plugs.AssignCurrentUser do
  @moduledoc false
  import Plug.Conn

  alias Accent.UserAuthFetcher

  def init(_), do: nil

  @doc """
  Takes a Plug.Conn and fetch the associated user giving the Authorization HTTP header.
  Fallbacks to the "authorization" query param to handle services without HTTP headers access (like webhooks).
  It assigns nil if any of the steps fails.
  """
  def call(conn, _opts) do
    conn
    |> get_req_header("authorization")
    |> List.first()
    |> fallback_query_param_token(conn)
    |> UserAuthFetcher.fetch()
    |> fallback_session_user(conn)
    |> case do
      nil ->
        assign(conn, :current_user, nil)

      user ->
        Logger.metadata(current_user: user.email || user.id)

        assign(conn, :current_user, user)
    end
  end

  defp fallback_query_param_token(token, _) when not is_nil(token), do: token

  defp fallback_query_param_token(nil, %{params: %{"authorization" => token}}) when is_binary(token) do
    "Bearer " <> token
  end

  defp fallback_query_param_token(_, _) do
    nil
  end

  defp fallback_session_user(nil, conn) do
    case get_session(conn, :user_id) do
      user_id when is_binary(user_id) -> UserAuthFetcher.fetch_by_id(user_id)
      _ -> nil
    end
  end

  defp fallback_session_user(user, _) do
    user
  end
end
