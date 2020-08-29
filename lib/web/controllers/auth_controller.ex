defmodule Accent.AuthController do
  use Phoenix.Controller

  alias Accent.UserRemote.Authenticator
  alias Accent.Router.Helpers, as: Routes

  plug :ueberauth

  def callback(conn = %{assigns: %{ueberauth_auth: auth}}, _) do
    case Authenticator.authenticate(auth) do
      {:ok, token} ->
        redirect(conn, to: webapp_url(conn) <> "?token=" <> token.token)

      _ ->
        redirect(conn, external: webapp_url(conn))
    end
  end

  def callback(conn, _) do
    redirect(conn, external: webapp_url(conn))
  end

  def ueberauth(conn, _) do
    Ueberauth.call(conn, Ueberauth.init())
  end

  defp webapp_url(conn) do
    Routes.web_app_path(conn, [])
  end
end
