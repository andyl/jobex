defmodule CrowWeb.PageControllerTest do
  use CrowWeb.ConnCase

  alias CrowData.Repo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  # test "GET /", %{conn: conn} do
  #   conn = get(conn, "/")
  #   assert html_response(conn, 200) =~ "Cron"
  # end
end
