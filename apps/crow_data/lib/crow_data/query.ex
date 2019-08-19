defmodule CrowData.Query do

  alias CrowData.Repo
  alias CrowData.Ctx.ObanJob
  import Ecto.Query

  def all_jobs do
    from(j in ObanJob, preload: [:results]) 
    |> Repo.all()
  end

  def job_states do
      from(
        j in ObanJob,
        group_by: j.state,
        select: {j.state, count(j.id)}
      )
      |> Repo.all()

      default_states()
  end

  defp default_states do
    %{
      "executing" => 0,
      "available" => 0,
      "scheduled" => 0,
      "retryable" => 0,
      "discarded" => 0,
      "completed" => 0
    }
  end

  def job_queues do
  end

  def job_types do
  end
end
