defmodule Accent.AuthController do
  use Phoenix.Controller, formats: []

  alias Accent.UserRemote.Authenticator
  alias Ueberauth.Strategy.Helpers

  plug(:ueberauth)

  def request(conn, _params) do
    redirect(conn, external: Helpers.callback_url(conn))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _) do
    case Authenticator.authenticate(auth) do
      {:ok, token} ->
        conn
        |> put_session(:user_id, token.user_id)
        |> redirect(to: "/?auth=" <> token.user_id)

      _ ->
        redirect(conn, to: "/")
    end
  end

  def callback(conn, _) do
    redirect(conn, to: "/")
  end

  def ueberauth(conn, _) do
    Ueberauth.call(conn, Ueberauth.init())
  end
end
