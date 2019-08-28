defmodule CrowData.Worker.Serial do
  use Oban.Worker, queue: "serial", max_attempts: 3

  @impl Oban.Worker

  def perform(args, job) do
    CrowData.Worker.Base.perform(args, job)
  end
end
