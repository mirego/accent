defmodule AccentTest.WebappController do
  use Accent.ConnCase

  test "index", %{conn: conn} do
    response =
      conn
      |> get(web_app_path(conn, []))

    assert response.status == 200
    assert response.state == :sent
    assert get_resp_header(response, "content-type") == ["text/html; charset=utf-8"]
  end

  test "catch all", %{conn: conn} do
    response =
      conn
      |> get("/app/foo")

    assert response.status == 200
    assert response.state == :sent
    assert get_resp_header(response, "content-type") == ["text/html; charset=utf-8"]
  end
end
