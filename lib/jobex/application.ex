defmodule Jobex.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: JobexIo.PubSub},
      JobexCore.Repo,
      JobexCore.Scheduler,
      {Oban, Application.get_env(:jobex, Oban)},
      Supervisor.child_spec({Phoenix.PubSub, name: JobexWeb.PubSub}, id: JobexWeb.PubSub),
      JobexWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Jobex.Supervisor]
    result = Supervisor.start_link(children, opts)

    case result do
      {:ok, _pid} -> load_selected_csv()
      _ -> :ok
    end

    result
  end

  defp load_selected_csv do
    case JobexCore.CsvManager.selected_file() do
      nil -> :ok
      filename -> JobexCore.Scheduler.load_file(filename)
    end
  rescue
    _ -> :ok
  end

  def config_change(changed, _new, removed) do
    JobexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
