defmodule Accent.ErrorController do
  import Plug.Conn

  def handle_unauthorized(conn) do
    conn
    |> send_resp(:unauthorized, "Unauthorized")
    |> halt
  end

  def handle_not_found(conn) do
    conn
    |> send_resp(:not_found, "Not found")
    |> halt
  end
end
