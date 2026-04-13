defmodule JobexCore.Scheduler do
  use Quantum, otp_app: :jobex

  require Logger

  alias NimbleCSV.RFC4180, as: CSV

  def priv_dir do
    if Application.get_env(:jobex, :env) == :dev do
      "priv"
    else
      :code.priv_dir(:jobex)
      |> to_string()
    end
  end

  def load_csv(path) do
    priv_dir()
    |> Path.join(path)
    |> File.read!()
    |> String.replace(~r/ +/, " ")
    |> String.replace(", ", ",")
    |> CSV.parse_string
  end

  def load_file(filename) do
    path = Path.join(JobexCore.CsvManager.csv_dir(), filename)

    rows =
      path
      |> File.read!()
      |> String.replace(~r/ +/, " ")
      |> String.replace(", ", ",")
      |> CSV.parse_string()

    delete_all_jobs()
    load_all(rows)
  end

  def load_dev_jobs do
    load_file("dev_schedule.csv")
  end

  def load_prod_jobs do
    load_file("prod_schedule.csv")
  end

  defp load_all(joblst) do
    ensure_serial_queues(joblst)
    joblst
    |> Enum.each(&load_one(&1))
  end

  defp ensure_serial_queues(joblst) do
    joblst
    |> Enum.filter(fn row -> Enum.at(row, 1) == "serial" end)
    |> Enum.map(fn row -> Enum.at(row, 2) end)
    |> Enum.uniq()
    |> Enum.each(fn type ->
      queue_name = JobexCore.Job.serial_queue_name(type)
      Oban.start_queue(queue: String.to_atom(queue_name), limit: 1)
    end)
  end

  defp load_one(job_data) do
    case Enum.at(job_data, 0) |> Crontab.CronExpression.Parser.parse() do
      {:ok, schedule} ->
        func = Enum.at(job_data, 1) |> String.to_atom()
        args = [Enum.at(job_data, 2), Enum.at(job_data, 3)]
        task = {JobexCore.Job, func, args}
        new_job()
        |> Quantum.Job.set_schedule(schedule)
        |> Quantum.Job.set_task(task)
        |> add_job()

      {:error, reason} ->
        Logger.warning("Skipping invalid job row: #{inspect(job_data)} (#{inspect(reason)})")
    end
  end
end
