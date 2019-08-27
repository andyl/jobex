defmodule CrowData.Query do
  alias CrowData.Repo
  alias CrowData.Ctx.{ObanJob, Result}
  alias Modex.AltMap
  import Ecto.Query
  import Modex.AltMap

  # ----- SIDEBAR ALL -----

  def all_count do
    from(
      j in ObanJob,
      select: count(j.id)
    )
    |> Repo.one()
  end

  # ----- SIDEBAR DATA -----

  def side_data do
    %{
      all_count: all_count(),
      job_states: job_states(),
      job_queues: job_queues(),
      job_types: job_types()
    }
  end

  defp job_states do
    default_states = %{
      "executing" => 0,
      "available" => 0,
      "scheduled" => 0,
      "retryable" => 0,
      "discarded" => 0,
      "completed" => 0
    }

    query_data =
      from(
        j in ObanJob,
        group_by: j.state,
        select: %{j.state => count(j.id)}
      )
      |> Repo.all()

    merge_list(default_states, query_data)
  end

  defp job_queues do
    from(
      j in ObanJob,
      group_by: j.queue,
      select: %{j.queue => count(j.id)}
    )
    |> Repo.all()
    |> merge_list()
  end

  defp job_types do
    from(
      j in ObanJob,
      group_by: fragment("args -> 'type'"),
      select: %{fragment("args -> 'type' as type") => count(j.id)}
    )
    |> Repo.all()
    |> merge_list()
  end

  # ----- ALT ------
  
  def zall do
    fields = [:id, :args, :state, :attempted_at, :completed_at, results: [:attempt, :status, :stdout, :stderr]]
    from(
      j in ObanJob,
      order_by: {:desc, j.id},
      join: r in Result,
      on: j.id == r.oban_job_id,
      preload: :results,
      select: map(j, ^fields),
      limit: 5
    )
  end
  
  # ----- BODY DATA -----

  def job_query(uistate \\ %{field: nil, value: nil}) do
    fields = [:id, :args, :state, :attempted_at, :completed_at, :results]
    case uistate do
      %{field: nil, value: nil}       -> jq_all() 
      %{field: "all",   value: nil}   -> jq_all() 
      %{field: "state", value: state} -> jq_state(state) 
      %{field: "queue", value: queue} -> jq_queue(queue) 
      %{field: "type",  value: type}  -> jq_type(type) 
    end 
    |> Repo.all()
    |> AltMap.retake(fields)
  end

  defp jq_all do
    rq = from(
      r in Result,
      order_by: r.attempt,
      select: %{
        attempt: r.attempt,
        status:  r.status,
        stdout:  r.stdout,
        stderr:  r.stderr
      }
    )

    from(
      j in ObanJob, 
      order_by: {:desc, j.id}, 
      limit: 20,
      preload: [results: ^rq]
    )
  end

  defp jq_state(state) do
    from(j in jq_all(), where: j.state == ^state)
  end

  defp jq_queue(queue) do
    from(j in jq_all(), where: j.queue == ^queue)
  end

  defp jq_type(type) do
    from(j in jq_all(), where: fragment("args ->> 'type' = ?", ^type))
  end
end
