defmodule Accent.WebAppController do
  use Plug.Builder

  plug(:index)

  def index(conn, _) do
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> Plug.Conn.send_file(200, "priv/static/webapp/index.html")
  end
end
