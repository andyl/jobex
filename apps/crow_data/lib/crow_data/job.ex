defmodule CrowData.Job do
  def shell(type, cmd) do
    %{type: type, cmd: cmd}
    |> CrowData.Worker.Shell.new()
    |> Oban.insert()
  end
end
