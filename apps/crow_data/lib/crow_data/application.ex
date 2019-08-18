defmodule CrowData.Application do
  @moduledoc false

  use Application


  def start(_type, _args) do
    IO.inspect "***************************************************"
    IO.inspect Application.get_env(:crow_data, Oban)
    IO.inspect "***************************************************"

    children = [
      CrowData.Repo,
      {Oban, Application.get_env(:crow_data, Oban)}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CrowData.Supervisor)
  end
end
