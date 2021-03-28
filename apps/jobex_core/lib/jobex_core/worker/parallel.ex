defmodule JobexCore.Worker.Parallel do
  use Oban.Worker, queue: "parallel", max_attempts: 3

  @impl Oban.Worker

  def perform(args, job) do
    JobexCore.Worker.Base.perform(args, job)
  end
end
