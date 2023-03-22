defmodule JobexWeb.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, [name: JobexWeb.PubSub, adapter: Phoenix.PubSub.PG2]}, 
      JobexWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: JobexWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    JobexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
