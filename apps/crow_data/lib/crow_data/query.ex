defmodule CrowData.Query do
  alias CrowData.Repo
  alias CrowData.Ctx.{ObanJob, Result}
  import Ecto.Query
  import Modex.AltMap

  # ----- PAGING -----

  def page_size do
    24
  end

  def offset(page) do
    page_size() * (page - 1)
  end

  # ----- SIDEBAR COUNTS -----

  def all_count do
    from(
      j in ObanJob,
      select: count(j.id)
    )
    |> Repo.one()
  end

  def sidebar_count do
    %{
      all_count: all_count(),
      state_count: state_count(),
      queue_count: queue_count(),
      type_count: type_count(),
      alert_count: alert_count()
    }
  end

  def state_count do
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

  def queue_count do
    from(
      j in ObanJob,
      group_by: j.queue,
      select: %{j.queue => count(j.id)}
    )
    |> Repo.all()
    |> merge_list()
  end

  def type_count do
    from(
      j in ObanJob,
      group_by: fragment("args -> 'type'"),
      select: %{fragment("args -> 'type' as type") => count(j.id)}
    )
    |> Repo.all()
    |> merge_list()
  end

  def command_count(cmd) do
    cmd_qry =
      from(
        j in ObanJob,
        select: count(j.id),
        where: fragment("args->>'cmd' ilike ?", ^"%#{cmd}%")
      )

    %{cmd => cmd_qry |> Repo.one()}
  end

  def alert_count do
    speed_qry =
      from(
        j in ObanJob,
        select: count(j.id),
        where: fragment("(completed_at - attempted_at) >= '99 seconds'")
      )

    %{
      "speed" => speed_qry |> Repo.one(),
      "spike" => 0
    }
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

  def job_data(uistate \\ %{field: nil, value: nil, page: 1}) do
    case uistate do
      %{field: nil} -> uistate |> jdata_all()
      %{field: ""} -> uistate |> jdata_all()
      %{field: "all"} -> uistate |> jdata_all()
      %{field: "state"} -> uistate |> jdata_state()
      %{field: "queue"} -> uistate |> jdata_queue()
      %{field: "type"} -> uistate |> jdata_type()
      %{field: "command"} -> uistate |> jdata_command()
      %{field: "alert"} -> uistate |> jdata_alert()
    end
    |> Repo.all()
  end

  defp jdata_all(uistate) do
    rquery = from(r in Result, order_by: r.attempt)

    fields = [
      :id,
      :queue,
      :args,
      :state,
      :attempted_at,
      :completed_at,
      results: [:attempt, :stdout, :stderr, :status]
    ]

    pgsize = page_size()
    offset = offset(uistate.page)

    from(
      j in ObanJob,
      order_by: {:desc, j.id},
      limit: ^pgsize,
      offset: ^offset,
      select: map(j, ^fields),
      preload: [results: ^rquery]
    )
  end

  defp jdata_state(uistate) do
    from(j in jdata_all(uistate), where: j.state == ^uistate.value)
  end

  defp jdata_queue(uistate) do
    from(j in jdata_all(uistate), where: j.queue == ^uistate.value)
  end

  defp jdata_type(uistate) do
    from(j in jdata_all(uistate), where: fragment("args->>'type' = ?", ^uistate.value))
  end

  defp jdata_command(uistate) do
    from(j in jdata_all(uistate), where: fragment("args->>'cmd' ilike ?", ^"%#{uistate.value}%"))
  end

  defp jdata_alert(uistate) do
    case uistate.value do
      "speed" ->
        from(j in jdata_all(uistate),
          where: fragment("(completed_at - attempted_at) >= '99 seconds'")
        )

      "spike" ->
        from(j in jdata_all(uistate), where: j.id < 0)
    end
  end
end
