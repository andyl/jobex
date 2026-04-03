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
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    JobexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
