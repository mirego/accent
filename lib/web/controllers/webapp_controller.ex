defmodule Accent.WebAppController do
  use Plug.Builder

  plug(:index)

  @doc """
  Serves the static app built from the webapp folder.

  Since the build operation is done asynchronously on deploy, we need a maintenance page until
  the index.html is available.
  """
  def index(conn, _) do
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> maybe_clear_session()
    |> send_resp(:ok, Accent.WebappView.render())
  end

  defp maybe_clear_session(conn) do
    case Map.get(conn.query_params, "logout") do
      nil -> conn
      _ -> put_session(conn, :user_id, nil)
    end
  end
end
