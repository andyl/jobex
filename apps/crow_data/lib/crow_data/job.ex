defmodule CrowData.Job do
  def serial(type, cmd) do
    %{type: type, cmd: cmd}
    |> CrowData.Worker.Serial.new()
    |> Oban.insert()
  end

  def parallel(type, cmd) do
    %{type: type, cmd: cmd}
    |> CrowData.Worker.Parallel.new()
    |> Oban.insert()
  end
end
