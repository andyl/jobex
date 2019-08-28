defmodule CrowData.Worker.Base do

  alias CrowData.Ctx.Result
  alias CrowData.Repo

  def perform(args, job) do
    CrowWeb.Endpoint.broadcast_from(self(), "job-event", "shell-worker-start", %{})

    cmd_result = Porcelain.shell(args["cmd"])

    args = %{
      stdout: cmd_result.out,
      stderr: cmd_result.err,
      status: cmd_result.status,
      attempt: job.attempt,
      oban_job_id: job.id
    }

    db_result =
      %Result{}
      |> Result.changeset(args)
      |> Repo.insert()

    CrowWeb.Endpoint.broadcast_from(self(), "job-event", "shell-worker-finish", %{})

    db_result
  end
end
