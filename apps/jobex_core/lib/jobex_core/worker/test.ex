defmodule JobexCore.Worker.Test do
  use Oban.Worker, queue: "parallel", max_attempts: 3

  @impl Oban.Worker

  def perform(_job) do
    IO.inspect(">>")
  end
end
