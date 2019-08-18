defmodule CrowData.Worker.Shell do
  use Oban.Worker, queue: "events", max_attempts: 3

  @impl Oban.Worker

  def perform(var1, var2) do
    IO.inspect "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    IO.inspect var1
    IO.inspect var2
    IO.inspect "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
  end
end
