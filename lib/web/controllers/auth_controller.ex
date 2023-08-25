defmodule Accent.AuthController do
  use Phoenix.Controller

  alias Accent.UserRemote.Authenticator

  plug :ueberauth

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _) do
    case Authenticator.authenticate(auth) do
      {:ok, token} ->
        redirect(conn, to: "/?token=" <> token.token)

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
