defmodule AccentTest.ErrorController do
  use Accent.ConnCase

  test "unauthorized", %{conn: conn} do
    conn = Accent.ErrorController.handle_unauthorized(conn)

    assert conn.status == 401
    assert conn.resp_body == "Unauthorized"
    assert conn.state == :sent
  end

  test "not_found", %{conn: conn} do
    conn = Accent.ErrorController.handle_not_found(conn)

    assert conn.status == 404
    assert conn.resp_body == "Not found"
    assert conn.state == :sent
  end
end
