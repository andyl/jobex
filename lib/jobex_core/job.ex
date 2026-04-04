defmodule JobexCore.Job do
  def serial(type, cmd) do
    queue_name = serial_queue_name(type)
    Oban.start_queue(queue: String.to_atom(queue_name), limit: 1)

    %{type: type, cmd: cmd}
    |> JobexCore.Worker.Serial.new(queue: queue_name)
    |> Oban.insert()
  end

  def parallel(type, cmd) do
    %{type: type, cmd: cmd}
    |> JobexCore.Worker.Parallel.new()
    |> Oban.insert()
  end

  def serial_queue_name(type) do
    safe = type |> String.downcase() |> String.replace(~r/[^a-z0-9_]/, "_")
    "serial_#{safe}"
  end
end
