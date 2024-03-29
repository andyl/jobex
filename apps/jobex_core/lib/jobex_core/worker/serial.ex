defmodule JobexCore.Worker.Serial do
  use Oban.Worker, queue: "serial", max_attempts: 3

  @impl Oban.Worker

  def perform(job) do
    JobexCore.Worker.Base.perform(job)
  end
end
