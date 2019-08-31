defmodule CrowWeb.HomeController do
  use CrowWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:body_data, CrowData.Query.job_query())
    |> assign(:side_data, CrowData.Query.side_data())
    |> assign(:uistate,   %{field: nil, value: nil})
    |> render("index.html")
  end

  def schedule(conn, _params) do
    conn
    |> assign(:schedule, CrowData.Scheduler.jobs())
    |> render("schedule.html")
  end

  def jobs(conn, params) do
    conn
    |> assign(:job, CrowData.Query.job(params["id"]))
    |> render("jobs.html")
  end

  def admin(conn, _params) do
    conn
    |> render("admin.html")
  end
end
