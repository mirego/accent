defmodule Accent.AuthenticationController do
  use Plug.Builder

  alias Accent.UserRemote.Authenticator

  import Phoenix.Controller, only: [json: 2]

  plug(:fetch_authentication)
  plug(:create)

  def create(conn = %{assigns: %{user: user, token: token}}, _) do
    conn
    |> json(%{
      token: token.token,
      user: %{
        id: user.id,
        email: user.email,
        picture_url: user.picture_url,
        fullname: user.fullname
      }
    })
  end

  def create(conn, _) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: conn.assigns[:error]})
  end

  defp fetch_authentication(conn = %{params: %{"uid" => uid, "provider" => provider}}, _) do
    case Authenticator.authenticate(provider, uid) do
      {:ok, user, token} ->
        conn
        |> assign(:user, user)
        |> assign(:token, token)

      {:error, error} ->
        assign(conn, :error, error)
    end
  end

  defp fetch_authentication(conn, _), do: assign(conn, :error, "Invalid params")
end
