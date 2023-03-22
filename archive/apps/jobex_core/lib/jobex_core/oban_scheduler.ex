defmodule JobexCore.ObanScheduler do

  alias NimbleCSV.RFC4180, as: CSV

  def priv_dir do
    if Application.get_env(:jobex_core, :env) == :dev do
      "apps/jobex_core/priv"
    else
      :code.priv_dir(:jobex_core)
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

  def load_dev_jobs do
    dev_jobs() 
    |> load_all()
  end

  def load_prod_jobs do
    prod_jobs() 
    |> load_all()
  end
  
  defp dev_jobs do
    "dev_schedule.csv" |> load_csv()
  end

  defp prod_jobs do
    "prod_schedule.csv" |> load_csv()
  end

  defp load_all(_joblst) do
    # IO.inspect "+++++++++++++++++++++++++++++++++++++++"
    # joblst 
    # |> Enum.map(&tuplize/1)
    # |> IO.inspect()
    # |> Oban.set_crontab()
    # IO.inspect Oban.config()
  end

  # defp tuplize([expression, mod, type, cmd]) do
  #   {expression, worker_module(mod), args: %{type: type, cmd: cmd}}
  # end

  # defp worker_module(mod) do
  #   case mod do
  #     "serial" -> JobexCore.Worker.Serial
  #     "parallel" -> JobexCore.Worker.Parallel
  #     _ -> JobexCore.Worker.Serial
  #   end
  # end
end
