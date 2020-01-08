defmodule Accent.BadgeController do
  use Phoenix.Controller

  import Canary.Plugs

  alias Accent.BadgeGenerator
  alias Accent.Project

  @svg_content_type "image/svg+xml"

  plug(:load_resource, model: Project)
  plug(:fetch_badge)

  def fetch_badge(conn, _) do
    conn.assigns[:project]
    |> BadgeGenerator.generate(conn.private[:phoenix_action])
    |> case do
      {:ok, badge} -> assign(conn, :badge, badge)
      {:error, _} -> conn |> send_resp(500, "internal server error") |> halt()
    end
  end

  def percentage_reviewed_count(conn, _params), do: send_badge_resp(conn)
  def conflicts_count(conn, _params), do: send_badge_resp(conn)
  def reviewed_count(conn, _params), do: send_badge_resp(conn)
  def translations_count(conn, _params), do: send_badge_resp(conn)

  defp send_badge_resp(conn) do
    conn
    |> put_resp_content_type(@svg_content_type)
    |> send_resp(:ok, conn.assigns[:badge])
  end
end
