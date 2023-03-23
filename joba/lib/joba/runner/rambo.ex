defmodule Joba.Runner.Rambo do
  def exec(cmd) do
    cmd
    |> String.replace(";", "&&")
    |> String.split("&&")
    |> Enum.map(&cmd_tuple/1)
    |> Enum.reduce({:ok}, &cmd_run/2)
    |> package_result()
  end

  def cmd_tuple(string) do
    [h | t] = string |> String.trim() |> String.split(" ")
    {h, t}
  end

  def cmd_run({cmd, args}, acc) do
    IO.inspect {cmd, args, acc}, label: "CMD_RUN"
    case elem(acc, 0) do
      :ok -> Rambo.run(cmd, args, log: false)
      _ -> acc
    end
  end

  defp package_result(tuple) do
    case tuple do
      {:ok, result} -> result
      {:error, msg} -> errmsg(msg)
    end
  end

  defp errmsg(msg) do
    %{
      err: msg,
      out: "Error: #{msg}",
      status: 127
    }
  end
end
