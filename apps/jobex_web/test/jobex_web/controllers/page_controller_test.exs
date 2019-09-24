defmodule JobexWeb.PageControllerTest do
  use JobexWeb.ConnCase

  alias JobexData.Repo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 302) =~ "You"
  end
end
