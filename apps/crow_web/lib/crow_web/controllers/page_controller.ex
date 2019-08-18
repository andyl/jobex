defmodule CrowWeb.PageController do
  use CrowWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
