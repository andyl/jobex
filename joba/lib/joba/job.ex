defmodule Joba.Job do
  def serial(type, cmd) do
    %{type: type, cmd: cmd}
    |> Joba.Worker.Serial.new()
    |> Oban.insert()
  end

  def parallel(type, cmd) do
    %{type: type, cmd: cmd}
    |> Joba.Worker.Parallel.new()
    |> Oban.insert()
  end
end
