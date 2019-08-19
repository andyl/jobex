defmodule CrowData.Worker.Shell do
  use Oban.Worker, queue: "command", max_attempts: 3

  @impl Oban.Worker

  alias CrowData.Ctx.Result
  alias CrowData.Repo

  def perform(args, job) do
    result = Porcelain.shell(args["cmd"])
    args = %{
      stdout: result.out,
      stderr: result.err,
      status: result.status,
      attempt: job.attempt,
      oban_job_id: job.id
    }

    key = %Result{}
    |> Result.changeset(args)
    |> Repo.insert()

    IO.inspect "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    IO.inspect args
    IO.inspect job
    IO.inspect result
    IO.inspect key
    IO.inspect "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
  end
end
