defmodule JobexCore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      JobexWeb.Telemetry,
      JobexCore.Repo,
      {Phoenix.PubSub, name: JobexCore.PubSub},
      {Finch, name: JobexCore.Finch},
      JobexWeb.Endpoint,
      JobexCore.Scheduler,
      {Oban, Application.fetch_env!(:jobex_core, Oban)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: JobexCore.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JobexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
