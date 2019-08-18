defmodule CrowWeb.PageControllerTest do
  use CrowWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "CrowWeb"
  end
end
