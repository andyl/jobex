defmodule CrowWeb.HomeController do
  use CrowWeb, :controller

  def index(conn, _params) do
    IO.inspect CrowData.Query.job_all()
    conn
    |> assign(:state_qry, CrowData.Query.job_states())
    |> assign(:queue_qry, CrowData.Query.job_queues())
    |> assign(:types_qry, CrowData.Query.job_types())
    |> assign(:uistate,   %{field: nil, value: nil})
    |> assign(:job_list,  CrowData.Query.job_all())
    |> render("index.html")
  end

  def urls(conn, _params) do
    render(conn, "urls.html")
  end

  def logs(conn, _params) do
    render(conn, "logs.html")
  end

  def stats(conn, _params) do
    render(conn, "stats.html")
  end
end
