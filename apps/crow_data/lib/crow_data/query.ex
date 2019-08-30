defmodule CrowData.Query do
  alias CrowData.Repo
  alias CrowData.Ctx.{ObanJob, Result}
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

  # ----- JOB -----

  def job(id) do
    from(
      j in ObanJob,
      where: j.id == ^id,
      preload: [:results]
    )
    |> Repo.one()
  end

  # ----- BODY DATA -----

  def job_query(uistate \\ %{field: nil, value: nil}) do
    case uistate do
      %{field: nil, value: nil}         -> jq_all() 
      %{field: "all",     value: nil}   -> jq_all() 
      %{field: "state",   value: state} -> jq_state(state) 
      %{field: "queue",   value: queue} -> jq_queue(queue) 
      %{field: "type",    value: type}  -> jq_type(type) 
      %{field: "command", value: cmd}   -> jq_cmd(cmd) 
    end 
    |> Repo.all()
  end

  defp jq_all do
    rquery = from(r in Result, order_by: r.attempt)
    fields = [:id, :queue, :args, :state, :attempted_at, :completed_at, results: [:attempt, :stdout, :stderr, :status]]

    from(
      j in ObanJob, 
      order_by: {:desc, j.id}, 
      limit: 24,
      select: map(j, ^fields),
      preload: [results: ^rquery]
    )
  end

  defp jq_cmd(cmd) do
    from(j in jq_all(), where: fragment("args->>'cmd' ilike ?", ^"%#{cmd}%"))
  end

  defp jq_state(state) do
    from(j in jq_all(), where: j.state == ^state)
  end

  defp jq_queue(queue) do
    from(j in jq_all(), where: j.queue == ^queue)
  end

  defp jq_type(type) do
    from(j in jq_all(), where: fragment("args->>'type' = ?", ^type))
  end
end
