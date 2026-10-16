defmodule AccentTest.BadgeController do
  use Accent.ConnCase, async: true

  alias Accent.HTTPClient
  alias Accent.Project
  alias Plug.Conn
  alias Req.Test, as: ReqTest

  defp behave_like_valid_response(response) do
    assert response.status == 200
    assert response.resp_body == "<svg></svg>"
    assert get_resp_header(response, "content-type") == ["image/svg+xml; charset=utf-8"]
  end

  setup do
    id = Ecto.UUID.generate()
    project = Factory.insert(Project, id: id, name: "project", main_color: "#f00")

    {:ok, %{project: project}}
  end

  defp stub_badge_service do
    ReqTest.stub(HTTPClient, fn conn -> Conn.send_resp(conn, 200, "<svg></svg>") end)
  end

  test "internal error on generator", %{conn: conn, project: project} do
    ReqTest.stub(HTTPClient, &ReqTest.transport_error(&1, :econnrefused))

    response = get(conn, badge_path(conn, :percentage_reviewed_count, project.id))

    assert response.status == 500
    assert response.resp_body == "internal server error"
  end

  test "percentage_reviewed_count", %{conn: conn, project: project} do
    stub_badge_service()

    response = get(conn, badge_path(conn, :percentage_reviewed_count, project.id))

    behave_like_valid_response(response)
  end

  test "translations_count", %{conn: conn, project: project} do
    stub_badge_service()

    response = get(conn, badge_path(conn, :translations_count, project.id))

    behave_like_valid_response(response)
  end

  test "reviewed_count", %{conn: conn, project: project} do
    stub_badge_service()

    response = get(conn, badge_path(conn, :reviewed_count, project.id))

    behave_like_valid_response(response)
  end

  test "conflicts", %{conn: conn, project: project} do
    stub_badge_service()

    response = get(conn, badge_path(conn, :conflicts_count, project.id))

    behave_like_valid_response(response)
  end
end
