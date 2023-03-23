defmodule JobexCore.Job do
  def serial(type, cmd) do
    %{type: type, cmd: cmd}
    |> JobexCore.Worker.Serial.new()
    |> Oban.insert()
  end

  def parallel(type, cmd) do
    %{type: type, cmd: cmd}
    |> JobexCore.Worker.Parallel.new()
    |> Oban.insert()
  end
end
