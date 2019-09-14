defmodule CrowData.Worker.Base do

  alias CrowData.Ctx.Result
  alias CrowData.Runner
  alias CrowData.Repo

  def perform(args, job) do

    CrowWeb.Endpoint.broadcast_from(self(), "job-event", "shell-worker-start", %{})

    cmd_result = Runner.Porcelain.exec(args["cmd"])
    # cmd_result = Runner.Rambo.exec(args["cmd"])

    args = %{
      stdout: cmd_result.out,
      stderr: err_msg(cmd_result),
      status: cmd_result.status,
      attempt: job.attempt,
      oban_job_id: job.id
    }

    %Result{}
    |> Result.changeset(args)
    |> Repo.insert()

    CrowWeb.Endpoint.broadcast_from(self(), "job-event", "shell-worker-finish", %{})

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
