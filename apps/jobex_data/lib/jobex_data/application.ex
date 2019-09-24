defmodule JobexData.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children =
        [
          JobexData.Repo,
          JobexData.Scheduler,
          {Oban, Application.get_env(:jobex_data, Oban)}
        ]

    Supervisor.start_link(children, strategy: :one_for_one, name: JobexData.Supervisor)
  end
end
