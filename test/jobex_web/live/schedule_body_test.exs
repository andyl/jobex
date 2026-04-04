defmodule JobexWeb.Live.ScheduleBodyTest do
  use JobexWeb.ConnCase

  import Phoenix.LiveViewTest

  alias JobexCore.Scheduler

  setup %{conn: conn} do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(JobexCore.Repo)

    tmp_dir = Path.join(System.tmp_dir!(), "jobex_lv_test_#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp_dir)
    System.put_env("JOBEX_CSV_DIR", tmp_dir)

    content = "SCHEDULE,QUEUE,TYPE,COMMAND\n* * * * *,serial,test,date\n"
    File.write!(Path.join(tmp_dir, "test.csv"), content)
    File.write!(Path.join(tmp_dir, ".jobex.yml"), "selected: test.csv\n")

    Scheduler.load_file("test.csv")

    on_exit(fn ->
      Scheduler.delete_all_jobs()
      File.rm_rf!(tmp_dir)
      System.delete_env("JOBEX_CSV_DIR")
    end)

    {:ok, view, _html} = live_isolated(conn, JobexWeb.Live.Schedule.Body)

    {:ok, view: view}
  end

  test "create_job with empty schedule shows validation error", %{view: view} do
    view |> element("a", "Add Job") |> render_click()

    html =
      view
      |> form("form[phx-submit=create_job]", %{schedule: "", queue: "serial", type: "t", command: "date"})
      |> render_submit()

    assert html =~ "Schedule is required"
  end

  test "create_job with valid data succeeds", %{view: view} do
    view |> element("a", "Add Job") |> render_click()

    html =
      view
      |> form("form[phx-submit=create_job]", %{schedule: "*/2 * * * *", queue: "serial", type: "new", command: "hostname"})
      |> render_submit()

    refute html =~ "Schedule is required"
    refute html =~ "Invalid cron expression"
    assert html =~ "hostname"
  end

  test "create_job with invalid cron shows error", %{view: view} do
    view |> element("a", "Add Job") |> render_click()

    html =
      view
      |> form("form[phx-submit=create_job]", %{schedule: "bad", queue: "serial", type: "t", command: "date"})
      |> render_submit()

    assert html =~ "Invalid cron expression"
  end
end
