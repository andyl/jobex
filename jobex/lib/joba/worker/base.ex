defmodule Joba.Worker.Base do

  alias Joba.Sch.Result
  alias Joba.Runner
  alias Joba.Repo

  def perform(job) do

    # JobexIo.broadcast("shell-worker-start", %{})

    cmd_result = Runner.Rambo.exec(job.args["cmd"])

    result = %{
      stdout: cmd_result.out,
      stderr: err_msg(cmd_result),
      status: cmd_result.status,
      attempt: job.attempt,
      oban_job_id: job.id
    }

    %Result{}
    |> Result.changeset(result)
    |> Repo.insert()

    # JobexIo.broadcast("shell-worker-finish", %{})

    return_code(cmd_result)
  end

  defp err_msg(cmd_result) do
    case cmd_result.status do
      127 -> "command not found"
      _ -> cmd_result.err
    end
  end

  defp return_code(cmd_result) do
    case cmd_result.status do
      0 -> :ok
      127 -> {:error, "(127) command not found"}
      code -> {:error, "(#{code}) error"}
    end
  end
end
