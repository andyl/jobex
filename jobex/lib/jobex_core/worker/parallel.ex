defmodule JobexCore.Worker.Parallel do
  use Oban.Worker, queue: "parallel", max_attempts: 3

  # @impl Oban.Worker
  #
  # @impl true
  def perform(job) do
    JobexCore.Worker.Base.perform(job)
  end
end
