defmodule JobexCore.Scheduler do
  use Quantum, otp_app: :jobex

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
    IO.puts "*****"
    IO.puts "LOADING CSV #{path}"
    IO.puts "*****"
    priv_dir()
    |> Path.join(path)
    |> File.read!()
    |> String.replace(~r/ +/, " ")
    |> String.replace(", ", ",")
    |> CSV.parse_string
  end

  def load_file(filename) do
    path = Path.join(JobexCore.CsvManager.csv_dir(), filename)

    IO.puts "*****"
    IO.puts "LOADING CSV #{path}"
    IO.puts "*****"

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
    joblst
    |> Enum.each(&load_one(&1))
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
        IO.puts("Skipping invalid job row: #{inspect(job_data)} (#{inspect(reason)})")
    end
  end
end
