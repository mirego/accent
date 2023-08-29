defmodule Accent.AuthController do
  use Phoenix.Controller

  alias Accent.UserRemote.Authenticator
  alias Ueberauth.Strategy.Helpers

  plug(Ueberauth, base_path: "/auth")

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

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
end
