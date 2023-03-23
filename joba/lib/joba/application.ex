defmodule Joba.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      JobaWeb.Telemetry,
      Joba.Repo,
      {Phoenix.PubSub, name: Joba.PubSub},
      {Finch, name: Joba.Finch},
      JobaWeb.Endpoint,
      Joba.Scheduler,
      {Oban, Application.fetch_env!(:joba, Oban)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Joba.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JobaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
