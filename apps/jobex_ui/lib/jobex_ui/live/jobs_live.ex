defmodule JobexUi.JobsLive do
  use JobexUi, :live_view

  # ----- lifecycle callback -----

  @impl true
  def mount(params, _session, socket) do

    uistate = %{
      field: params["field"] || "all",
      value: params["value"] || "na",
      page:  params["page"] |> to_int()
    }
    
    job_count = job_count(uistate)
    
    # body_data: JobexCore.Query.job_data(uistate),

    opts = %{
      rand: :rand.uniform(10000), 
      uistate: uistate,
      job_count: job_count,
      num_pages: num_pages(job_count),
      timestamp: hdr_timestamp()
    }

    {:ok, assign(socket, opts: opts)}
  end

  # ----- view helpers -----

  # ----- data helpers -----

  defp job_count(uistate) do
    case uistate.field do
      nil       -> JobexCore.Query.all_count()
      "all"     -> JobexCore.Query.all_count()
      "state"   -> JobexCore.Query.state_count()[uistate.value]
      "type"    -> JobexCore.Query.type_count()[uistate.value]
      "queue"   -> JobexCore.Query.queue_count()[uistate.value]
      "command" -> JobexCore.Query.command_count(uistate.value)[uistate.value]
      "alert"   -> JobexCore.Query.alert_count()[uistate.value]
      _         -> JobexCore.Query.all_count()
    end
  end

  defp num_pages(job_count) do
    if job_count > 0 do
      size = JobexCore.Query.page_size()
      rema = if rem(job_count, size) > 0, do: 1, else: 0
      div(job_count, size) + rema
    else
      0
    end
  end

  defp to_int(nil), do: 1
  defp to_int(arg) when is_integer(arg), do: arg
  defp to_int(arg) when is_binary(arg), do: String.to_integer(arg)

  defp hdr_timestamp do
    Timex.now("US/Pacific")
    |> Timex.format!("%Y %b %d | %H:%M:%S", :strftime)
  end
  
  # ----- message handlers -----

  # ----- event handlers -----

end
