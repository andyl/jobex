defmodule JobexWeb.Jobs.HomeLive do
  use JobexWeb, :live_view

  alias JobexWeb.Jobs.Components.{HomeBody, HomeSidebar}

  def mount(_alt, _session, socket) do
    JobexWeb.Endpoint.subscribe("arrow-key")
    JobexWeb.Endpoint.subscribe("job-refresh")
    JobexWeb.Endpoint.subscribe("time-tick")
    :timer.send_interval(1000, self(), :tick_sec)

    opts = %{
      tick: 0
    }

    {:ok, assign(socket, opts)}
  end

  def handle_params(params, _url, socket) do
    uistate = %{
      field: params["field"] || "all",
      value: params["value"] || "na",
      page: params["page"] |> to_int()
    }

    job_count = job_count(uistate)

    opts = %{
      body_data: JobexCore.Query.job_data(uistate),
      uistate: uistate,
      job_count: job_count,
      num_pages: num_pages(job_count),
    }

    {:noreply, assign(socket, opts)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex">
      <div class="bg-blue-200 w-28 p-4">
        <HomeSidebar.job_list />
      </div>
      <div class="bg-green-200 flex-auto p-4">
        <HomeBody.job_header tick={@tick} />
        <HomeBody.job_table body_data={@body_data} uistate={@uistate} />
      </div>
    </div>
    """
  end

  # ----- helpers -----

  defp to_int(nil), do: 1
  defp to_int(arg) when is_integer(arg), do: arg
  defp to_int(arg) when is_binary(arg), do: String.to_integer(arg)

  defp job_count(uistate) do
    case uistate.field do
      nil -> JobexCore.Query.all_count()
      "all" -> JobexCore.Query.all_count()
      "state" -> JobexCore.Query.state_count()[uistate.value]
      "type" -> JobexCore.Query.type_count()[uistate.value]
      "queue" -> JobexCore.Query.queue_count()[uistate.value]
      "command" -> JobexCore.Query.command_count(uistate.value)[uistate.value]
      "alert" -> JobexCore.Query.alert_count()[uistate.value]
      _ -> JobexCore.Query.all_count()
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

  # ----- message handlers -----

  # def handle_info(%{topic: "job-refresh"}, socket) do
  #   uistate = socket.assigns.uistate
  #   job_count = job_count(uistate)
  #
  #   opts = %{
  #     body_data: JobexCore.Query.job_data(uistate),
  #     job_count: job_count,
  #     num_pages: num_pages(job_count)
  #   }
  #
  #   {:noreply, assign(socket, opts)}
  # end

  # def handle_info(%{topic: "time-tick"}, socket) do
  #   new_timestamp = hdr_timestamp()
  #   {:noreply, assign(socket, %{timestamp: new_timestamp})}
  # end

  def handle_info(:tick_sec, socket) do
    {:noreply, update(socket, :tick, &(&1 + 1))}
  end

  def handle_info(target, socket) do
    IO.inspect(target, label: "TARGET")
    IO.inspect(socket, label: "SOCKET")
    {:noreply, socket}
  end
end
