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

    Supervisor.start_link(children, strategy: :one_for_one, name: JobexCore.Supervisor)
  end
end
