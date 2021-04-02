defmodule JobexIo.Application do

  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: JobexIo.PubSub}
    ]

    opts = [strategy: :one_for_one, name: JobexIo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
