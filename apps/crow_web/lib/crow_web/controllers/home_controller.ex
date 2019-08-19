defmodule CrowWeb.HomeController do
  use CrowWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:allcount,  CrowData.Query.all_count())
    |> assign(:state_qry, CrowData.Query.job_states())
    |> assign(:queue_qry, CrowData.Query.job_queues())
    |> assign(:types_qry, CrowData.Query.job_types())
    |> assign(:job_list,  CrowData.Query.job_all())
    |> assign(:uistate,   %{field: nil, value: nil})
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
