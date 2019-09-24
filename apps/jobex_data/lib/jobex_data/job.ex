defmodule JobexData.Job do
  def serial(type, cmd) do
    %{type: type, cmd: cmd}
    |> JobexData.Worker.Serial.new()
    |> Oban.insert()
  end

  def parallel(type, cmd) do
    %{type: type, cmd: cmd}
    |> JobexData.Worker.Parallel.new()
    |> Oban.insert()
  end
end
