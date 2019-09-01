defmodule CrowWeb.HomeController do
  use CrowWeb, :controller

  def index(conn, _params) do
    conn
    |> redirect(to: "/home")
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

  def help(conn, _params) do
    conn
    |> render("help.html")
  end
end
