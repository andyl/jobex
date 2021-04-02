defmodule JobexCore.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children =
        [
          JobexCore.Repo,
          JobexCore.Scheduler,
          {Oban, Application.get_env(:jobex_core, Oban)}
        ]

    IO.puts "*****\nSTARTING CORE\n*****"

    opts = [strategy: :one_for_one, name: JobexCore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
