defmodule JobexWeb.HomeControllerTest do
  use JobexWeb.ConnCase

  alias JobexCore.Repo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "GET /home", %{conn: conn} do
    conn = get(conn, "/home")
    assert html_response(conn, 200) =~ "Jobex"
  end

  test "GET /schedule", %{conn: conn} do
    conn = get(conn, "/schedule")
    assert html_response(conn, 200) =~ "Schedule"
  end
end
