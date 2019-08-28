defmodule CrowData.Scheduler do
  use Quantum.Scheduler, otp_app: :crow_data
  
  defp dev_jobs do
    [
      ["* * * * *",   "serial",   "sleep10", "sleep 10; date"],
      ["* * * * *",   "serial",   "sleep20", "sleep 20; date"],
      ["* * * * *",   "parallel", "sleep30", "sleep 30; date"],
      ["* * * * *",   "parallel", "sleep30", "sleep 30; date"],
      ["* * * * *",   "parallel", "sleep30", "sleep 30; date"],
      ["* * * * *",   "serial",   "date",    "date"],
      ["*/2 * * * *", "serial",   "who",     "whoami"],
      ["*/3 * * * *", "serial",   "host",    "hostname"],
      ["*/4 * * * *", "serial",   "uptime",  "uptime"]
    ]
  end

  defp prod_jobs do
    [
      ["* * * * *",   "serial",   "sleep10", "sleep 10; date"],
      ["* * * * *",   "serial",   "sleep20", "sleep 20; date"],
      ["* * * * *",   "parallel", "sleep30", "sleep 30; date"]
    ]
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
