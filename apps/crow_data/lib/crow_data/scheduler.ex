defmodule CrowData.Scheduler do
  use Quantum.Scheduler, otp_app: :crow_data

  alias NimbleCSV.RFC4180, as: CSV

  def priv_dir do
    if Application.get_env(:crow_data, :env) == :dev do
      "apps/crow_data/priv"
    else
      :code.priv_dir(:crow_data)
      |> to_string()
    end
  end

  def load_csv(path) do
    IO.inspect("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
    IO.inspect(Application.get_env(:crow_data, :env))
    IO.inspect(path)
    IO.inspect("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
    priv_dir()
    |> Path.join(path)
    |> IO.inspect()
    |> File.read!()
    |> IO.inspect()
    |> String.replace(~r/ +/, " ")
    |> String.replace(", ", ",")
    |> IO.inspect()
    |> CSV.parse_string
    |> IO.inspect()
  end
  
  defp dev_jobs do
    "dev_schedule.csv" |> load_csv()
  end

  defp prod_jobs do
    "prod_schedule.csv" |> load_csv()
  end

  defp load_all(joblst) do
    joblst 
    |> Enum.each(&(load_one(&1)))
  end

  defp load_one(job_data) do
    schedule = Enum.at(job_data, 0) |> Crontab.CronExpression.Parser.parse!() 
    func = Enum.at(job_data, 1) |> String.to_atom()
    args = [Enum.at(job_data, 2), Enum.at(job_data, 3)]
    task = {CrowData.Job, func, args}
    new_job()
    |> Quantum.Job.set_schedule(schedule)
    |> Quantum.Job.set_task(task)
    |> add_job()
  end

  def load_dev_jobs do
    delete_all_jobs()
    dev_jobs() |> load_all()
  end

  def load_prod_jobs do
    delete_all_jobs()
    prod_jobs() |> load_all()
  end
end
