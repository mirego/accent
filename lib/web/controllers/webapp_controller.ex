defmodule Accent.WebAppController do
  use Plug.Builder

  import Phoenix.Controller, only: [put_view: 2, render: 2]

  alias Accent.WebappView

  plug(:ensure_file_exists)
  plug(:index)

  @doc """
  Serves the static app built from the webapp folder.

  Since the build operation is done asynchronously on deploy, we need a maintenance page until
  the index.html is available.
  """
  def index(conn, _) do
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> send_file(200, conn.assigns[:file])
  end

  def ensure_file_exists(conn, _) do
    file = Application.app_dir(:accent, "priv/static/webapp/index.html")

    file
    |> File.read()
    |> case do
      {:error, _} ->
        conn
        |> put_view(WebappView)
        |> render("maintenance.html")

      _ ->
        assign(conn, :file, file)
    end
  end
end
