defmodule JobexWeb.Live.Home.Body do
  use JobexWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    JobexWeb.Endpoint.subscribe("job-refresh")
    if connected?(socket), do: schedule_next_tick()
    uistate = session["uistate"]
    job_count = job_count(uistate)

    opts = %{
      body_data: JobexCore.Query.job_data(uistate),
      uistate: uistate,
      job_count: job_count,
      num_pages: num_pages(job_count),
      timestamp: hdr_timestamp()
    }

    {:ok, assign(socket, opts)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex justify-between items-center mb-2" phx-keydown="keydown" phx-target="window">
      <b>{page_hdr_for(@uistate)}</b>
      <span>{@timestamp}</span>
    </div>
    <div class="text-sm">
      <table class="table table-xs table-bordered w-full border border-base-300 mb-4">
        <tbody>
          <%= for job <- @body_data do %>
            <tr class={row_class(job)}>
              <td>
                <a href={"/jobs/#{job.id}"} class="link">{job.id}</a>
              </td>
              <td>
                <.cell_link uistate={@uistate} field="state" value={job.state} />
              </td>
              <td>
                <.cell_link uistate={@uistate} field="queue" value={display_queue(job.queue)} />
              </td>
              <td>
                <.cell_link uistate={@uistate} field="type" value={job.args["type"]} />
              </td>
              <td>{tbl_start(job)}</td>
              <td class="text-right">
                <.secs_cell uistate={@uistate} job={job} />
              </td>
              <td>
                <.cmd_cell uistate={@uistate} job={job} />
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
      <nav class="pb-1">
        <div class="join flex justify-center">
          <.pg_btn uistate={@uistate} num_pages={@num_pages} action="page_min" icon="fa-angle-double-left" />
          <.pg_btn uistate={@uistate} num_pages={@num_pages} action="page_dec" icon="fa-angle-left" />
          <button class="btn btn-xs join-item btn-disabled">
            page {pg_msg(@uistate[:page] || 1, @num_pages)}
          </button>
          <.pg_btn uistate={@uistate} num_pages={@num_pages} action="page_inc" icon="fa-angle-right" />
          <.pg_btn uistate={@uistate} num_pages={@num_pages} action="page_max" icon="fa-angle-double-right" />
        </div>
      </nav>
    </div>
    """
  end

  # ----- components -----

  attr :uistate, :map, required: true
  attr :field, :string, required: true
  attr :value, :string, required: true

  defp cell_link(assigns) do
    active = assigns.uistate.field == assigns.field && assigns.uistate.value == assigns.value
    assigns = assign(assigns, :active, active)

    ~H"""
    <%= if @active do %>
      <b>{@value}</b>
    <% else %>
      <a href={"/home?field=#{@field}&value=#{@value}"}>{@value}</a>
    <% end %>
    """
  end

  attr :uistate, :map, required: true
  attr :job, :map, required: true

  defp secs_cell(assigns) do
    val = tbl_secs(assigns.uistate, assigns.job)
    assigns = assign(assigns, :val, val)

    ~H"""
    {Phoenix.HTML.raw(@val)}
    """
  end

  attr :uistate, :map, required: true
  attr :job, :map, required: true

  defp cmd_cell(assigns) do
    val = tbl_cmd(assigns.uistate, assigns.job)
    assigns = assign(assigns, :val, val)

    ~H"""
    {Phoenix.HTML.raw(@val)}
    """
  end

  attr :uistate, :map, required: true
  attr :num_pages, :integer, required: true
  attr :action, :string, required: true
  attr :icon, :string, required: true

  defp pg_btn(assigns) do
    page = assigns.uistate[:page] || 1
    num_pages = assigns.num_pages

    {disabled, new_page} =
      case assigns.action do
        "page_min" -> {page == 1 || num_pages == 0, 1}
        "page_dec" -> {page == 1 || num_pages == 0, Enum.max([page - 1, 1])}
        "page_inc" -> {page == num_pages || num_pages == 0, Enum.min([page + 1, num_pages])}
        "page_max" -> {page == num_pages || num_pages == 0, num_pages}
      end

    new_uistate = Map.merge(assigns.uistate, %{page: new_page})
    path = path_for(new_uistate)
    assigns = assign(assigns, disabled: disabled, path: path)

    ~H"""
    <%= if @disabled do %>
      <button class="btn btn-xs join-item btn-disabled"><i class={"fa #{@icon}"}></i></button>
    <% else %>
      <a href={@path} data-phx-link="patch" data-phx-link-state="push" class="btn btn-xs join-item">
        <i class={"fa #{@icon}"}></i>
      </a>
    <% end %>
    """
  end

  defp display_queue(queue) do
    if String.starts_with?(queue, "serial_"), do: "serial", else: queue
  end

  # ----- page_hdr helper -----

  defp page_hdr_for(uistate) do
    case uistate do
      %{field: nil, value: nil} -> "ALL JOBS"
      %{field: "all", value: _} -> "ALL JOBS"
      %{field: fld, value: val} -> "#{fld} / #{val}"
    end
  end

  defp schedule_next_tick do
    now = System.system_time(:millisecond)
    ms_into_interval = rem(now, 5000)
    delay = 5000 - ms_into_interval
    Process.send_after(self(), :time_tick, delay)
  end

  defp hdr_timestamp do
    DateTime.utc_now()
    |> DateTime.shift_zone!("America/Los_Angeles")
    |> Calendar.strftime("%Y %b %d | %H:%M:%S")
  end

  # ----- table helpers -----

  defp row_class(job) do
    %{
      "discarded" => "row-discarded",
      "retryable" => "row-retryable",
      "available" => "row-available",
      "executing" => "row-executing"
    }[job.state]
  end

  def tbl_start(job) do
    if job.attempted_at do
      job.attempted_at
      |> DateTime.shift_zone!("America/Los_Angeles")
      |> Calendar.strftime("%m-%d %H:%M")
    else
      nil
    end
  end

  def esecs(job), do: DateTime.diff(job.completed_at, job.attempted_at)

  defp tbl_secs(uistate, job) do
    if job.completed_at do
      secs = esecs(job)

      if secs >= 100 do
        if {uistate.field, uistate.value} == {"alert", "speed"} do
          "<b>#{secs}</b>"
        else
          "<a href='/home?field=alert&value=speed'>#{secs}</a>"
        end
      else
        "#{secs}"
      end
    else
      "NA"
    end
  end

  defp tbl_cmd(uistate, job) do
    cmd = job.args["cmd"]

    if cmd do
      cmd
      |> String.slice(0, 22)
      |> String.split(" ")
      |> Enum.map(&cmd_link(uistate, &1))
      |> Enum.join(" ")
    else
      ""
    end
  end

  defp cmd_link(uistate, word) do
    cleanword = String.replace(word, "...", "")

    if {uistate.field, uistate.value} == {"command", cleanword} do
      "<b>#{word}</b>"
    else
      "<a href='/home?field=command&value=#{cleanword}'>#{word}</a>"
    end
  end

  # ----- pagination helpers -----

  defp path_for(uistate) do
    "/home?field=#{uistate.field}&value=#{uistate.value}&page=#{uistate[:page] || 1}"
  end

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

  defp pg_msg(page, num_pages) do
    numpg = if num_pages == 0, do: 0, else: page
    "#{numpg} of #{num_pages}"
  end

  # ----- keyboard event handlers -----

  @impl true
  def handle_event("keydown", keypress = %{"key" => "ArrowLeft"}, socket) do
    oldpage = socket.assigns.uistate[:page] || 1
    newpage = if keypress["ctrlKey"], do: 1, else: Enum.max([oldpage - 1, 1])
    newstate = Map.merge(socket.assigns.uistate, %{page: newpage})
    newpath = %{newpath: path_for(newstate)}

    if newpage != oldpage && socket.assigns.num_pages != 0 do
      JobexWeb.Endpoint.broadcast_from(self(), "arrow-key", "page-nav", newpath)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("keydown", keypress = %{"key" => "ArrowRight"}, socket) do
    num_pages = socket.assigns.num_pages
    oldpage = socket.assigns.uistate[:page] || 1
    newpage = if keypress["ctrlKey"], do: num_pages, else: Enum.min([oldpage + 1, num_pages])
    newstate = Map.merge(socket.assigns.uistate, %{page: newpage})
    newpath = %{newpath: path_for(newstate)}

    if newpage != oldpage && num_pages != 0 do
      JobexWeb.Endpoint.broadcast_from(self(), "arrow-key", "page-nav", newpath)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("keydown", _keypress, socket), do: {:noreply, socket}

  # ----- pub/sub handlers -----

  @impl true
  def handle_info(%{topic: "job-refresh"}, socket) do
    uistate = socket.assigns.uistate
    job_count = job_count(uistate)

    opts = %{
      body_data: JobexCore.Query.job_data(uistate),
      job_count: job_count,
      num_pages: num_pages(job_count)
    }

    {:noreply, assign(socket, opts)}
  end

  @impl true
  def handle_info(:time_tick, socket) do
    schedule_next_tick()
    {:noreply, assign(socket, %{timestamp: hdr_timestamp()})}
  end
end
