defmodule CrowData.Runner.Rambo do
  def exec(cmd) do
    cmd
    |> String.split(";")
    |> Enum.map(&(String.split(&1)))

  end

  defp run(cmd) do
    cmd
    |> Rambo.run()
  end
end
