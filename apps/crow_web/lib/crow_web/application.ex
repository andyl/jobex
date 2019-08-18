defmodule CrowWeb.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      CrowWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: CrowWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    CrowWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
