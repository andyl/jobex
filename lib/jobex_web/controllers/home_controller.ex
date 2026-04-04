defmodule JobexWeb.HomeController do
  use JobexWeb, :controller

  def index(conn, _params) do
    conn
    |> redirect(to: "/home")
  end

  def schedule(conn, _params) do
    conn
    |> render(:schedule)
  end

  def jobs(conn, params) do
    conn
    |> assign(:job, JobexCore.Query.job(params["id"]))
    |> render(:jobs)
  end

  def admin(conn, _params) do
    schedule = JobexCore.Scheduler.jobs()
    env = Application.get_env(:jobex, :env)

    conn
    |> assign(:schedule, schedule)
    |> assign(:env, env)
    |> render(:admin)
  end

  def reload_csv(conn, _params) do
    case JobexCore.CsvManager.selected_file() do
      nil ->
        if Application.get_env(:jobex, :env) == :dev do
          JobexCore.Scheduler.load_dev_jobs()
        else
          JobexCore.Scheduler.load_prod_jobs()
        end

      filename ->
        JobexCore.Scheduler.load_file(filename)
    end

    conn
    |> put_flash(:info, "CSV schedule reloaded (#{length(JobexCore.Scheduler.jobs())} jobs loaded)")
    |> redirect(to: "/admin")
  end

  def help(conn, _params) do
    conn
    |> render(:help)
  end
end
