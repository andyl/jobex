defmodule JobexUi.BodyComponent do

  import Phoenix.HTML

  alias JobexUi.Util
  use Phoenix.LiveComponent

  # ----- lifecycle callbacks -----

  @impl true
  def mount(socket) do
    # JobexUi.Endpoint.subscribe("job-refresh")
    # JobexUi.Endpoint.subscribe("time-tick")
    {:ok, socket}
  end

  @impl true
  def update(session, socket) do
    iopts = session.session["opts"]
    jbcnt = job_count(iopts.uistate)
    xopts = %{
      body_data: JobexCore.Query.job_data(iopts.uistate),
      refresh: false, 
      job_count: jbcnt, 
      sidebar_count: JobexCore.Query.sidebar_count(), 
      num_pages: num_pages(jbcnt),
      timestamp: "TBD", #hdr_timestamp(), 
      uistate: iopts.uistate
    }
    {:ok, assign(socket, xopts)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <div class='row' phx-keydown='keydown' phx-target='window'>
      <div class='col-md-6'>
      <b><%= page_hdr_for(@uistate) %></b>
      </div> 
      <div class='col-md-6 text-right'>
      <%# @timestamp %>
      </div>
      <small>
      <table class='table table-sm table-bordered' style='margin-bottom: 20px;'>
        <%= for job <- @body_data do %>
          <tr <%= raw tbl_rowstyle(job) %>>
            <td> 
            <a href="/jobs/<%= job.id %>">
            <%= job.id %>
            </a>
            </td>
            <td> 
              <%= raw tbl_cell(@uistate, "state", job.state) %>
            </td>
            <td>
              <%= raw tbl_cell(@uistate, "queue", job.queue) %>
            </td>
            <td> 
              <%= raw tbl_cell(@uistate, "type", job.args["type"]) %>
            </td>
            <td><%= tbl_start(job) %></td>
            <td align='right'><%= raw tbl_secs(@uistate, job) %></td>
            <td><%= raw tbl_cmd(@uistate, job) %></td>
          </tr>
        <% end %>
      </table>
      <nav area-label="pagination" style='padding-bottom: 5px;'>
      <ul class="pagination justify-content-center">
      <%= raw pg_prev_links(assigns) %>
      <li class="page-item disabled">
      <a class="page-link" href='#'>page <%= pg_msg(@uistate[:page] || 1, @num_pages) %></a>
      </li>
      <%= raw pg_next_links(assigns) %>
      </ul>
      </nav>
      </small>
    </div>
    """
  end

  # ----- page_hdr helper -----

  defp page_hdr_for(uistate) do
    case uistate do
      %{field: nil, value: nil} -> "ALL JOBS"
      %{field: "all", value: _} -> "ALL JOBS"
      %{field: fld, value: val} -> "#{fld} / #{val}"
    end
  end

  defp hdr_timestamp do
    # Timex.now("US/Pacific")
    # |> Timex.format!("%Y %b %d | %H:%M:%S", :strftime)
    "YYMMDD"
  end
  
  # ----- table helpers -----

  defp tbl_rowstyle(job) do
    %{
      "discarded" => "style='background-color: #ffb3a7;'",
      "retryable" => "style='background-color: #ffc673;'",
      "available" => "style='background-color: lightyellow;'",
      "executing" => "style='background-color: #dbfad2;'"
    }[job.state]
  end

  defp tbl_cell(uistate, field, value) do
    if {uistate.field, uistate.value} == {field, value} do
      "<b>#{value}</b>"
    else
      """
      <a href="/home?field=#{field}&value=#{value}">
      #{value}
      </a>
      """
    end
  end

  def tbl_start(job) do
    if job.attempted_at do
      # job.attempted_at
      # |> Timex.Timezone.convert("PDT")
      # |> Timex.Format.DateTime.Formatters.Strftime.format!("%m-%d %H:%M")
      "YYMMDD"
    else
      nil
    end
  end

  def esecs(job), do: DateTime.diff(job.completed_at, job.attempted_at) 

  def tbl_secs(uistate, job) do
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
    job.args["cmd"]
    |> Phoenix.HTML.SimplifiedHelpers.Truncate.truncate(length: 22)
    |> split_if_present()
    |> Enum.map(&(cmd_link(uistate, &1)))
    |> Enum.join(" ")
  end

  defp split_if_present(input) do
    case input do
      nil -> [""]
      _ -> String.split(input, " ")
    end
  end

  defp cmd_link(uistate, word) do
    cleanword =
      word
      |> String.replace("...", "")
    if {uistate.field, uistate.value} == {"command", cleanword} do
      "<b>#{word}</b>"
    else
      """
      <a href='/home?field=command&value=#{cleanword}'>#{word}</a>
      """
    end
  end

  # ----- pagination helpers -----
  
  defp path_for(uistate) do
    "/home?field=#{uistate.field}&value=#{uistate.value}&page=#{uistate[:page] || 1}"
  end

  def my_live_link(lbl, path) do
    """
    <li class="page-item">
    #{Util.live_link(lbl, to: path, class: 'page-link')}
    </li>
    """
  end

  def page_link_for("page_min", assigns) do
    newstate = Map.merge(assigns.uistate, %{page: 1})
    my_live_link("<i class='fa fa-angle-double-left'></i>", path_for(newstate))
  end

  def page_link_for("page_dec", assigns) do
    oldpage = assigns.uistate[:page] || 1
    newpage = Enum.max([oldpage - 1, 1])
    newstate = Map.merge(assigns.uistate, %{page: newpage})
    my_live_link("<i class='fa fa-angle-left'></i>", path_for(newstate))
  end

  def page_link_for("page_inc", assigns) do
    num_pages = assigns.num_pages
    oldpage   = assigns.uistate[:page] || 1
    newpage   = Enum.min([oldpage + 1, num_pages])
    newstate  = Map.merge(assigns.uistate, %{page: newpage})
    my_live_link("<i class='fa fa-angle-right'></i>", path_for(newstate))
  end

  def page_link_for("page_max", assigns) do
    num_pages = assigns.num_pages
    newstate = Map.merge(assigns.uistate, %{page: num_pages})
    my_live_link("<i class='fa fa-angle-double-right'></i>", path_for(newstate))
  end
  
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

  defp pg_msg(page, num_pages) do
    numpg = if num_pages == 0, do: 0, else: page
    "#{numpg} of #{num_pages}"
  end

  defp pg_prev_links(assigns) do
    page = assigns.uistate[:page] || 1
    if page == 1 || assigns.num_pages == 0 do
    """
    <li class="page-item disabled"><a class="page-link" href='#'><i class='fa fa-angle-double-left'></i></a></li>
    <li class="page-item disabled"><a class="page-link" href='#'><i class='fa fa-angle-left'></i></a></li>
    """
    else
    """
    #{page_link_for("page_min", assigns)}
    #{page_link_for("page_dec", assigns)}
    """
    end
  end

  defp pg_next_links(assigns) do
    page = assigns.uistate[:page] || 1
    if page == assigns.num_pages || assigns.num_pages == 0 do
    """
    <li class="page-item disabled"><a class="page-link" href='#'><i class='fa fa-angle-right'></i></a></li>
    <li class="page-item disabled"><a class="page-link" href='#'><i class='fa fa-angle-double-right'></i></a></li>
    """
    else
    """
    #{page_link_for("page_inc", assigns)}
    #{page_link_for("page_max", assigns)}
    """
    end
  end

  # ----- event handlers -----

  @impl true
  def handle_event("keydown", keypress = %{"key" => "ArrowLeft"}, socket) do
    oldpage = socket.assigns.uistate[:page] || 1
    newpage = if keypress["ctrlKey"], do: 1, else: Enum.max([oldpage - 1, 1])
    newstate = Map.merge(socket.assigns.uistate, %{page: newpage})
    newpath   = %{newpath: path_for(newstate)}
    if newpage != oldpage && socket.assigns.num_pages != 0 do
      JobexUi.Endpoint.broadcast_from(self(), "arrow-key", "page-nav", newpath)
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("keydown", keypress = %{"key" => "ArrowRight"}, socket) do
    num_pages = socket.assigns.num_pages
    oldpage   = socket.assigns.uistate[:page] || 1
    newpage   = if keypress["ctrlKey"], do: num_pages, else: Enum.min([oldpage + 1, num_pages])
    newstate  = Map.merge(socket.assigns.uistate, %{page: newpage})
    newpath   = %{newpath: path_for(newstate)}
    if newpage != oldpage && num_pages != 0 do
      JobexUi.Endpoint.broadcast_from(self(), "arrow-key", "page-nav", newpath)
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("keydown", _keypress, socket) do
    {:noreply, socket}
  end
  
  # ----- message handlers -----

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
  def handle_info(%{topic: "time-tick"}, socket) do
    new_timestamp = hdr_timestamp()
    {:noreply, assign(socket, %{timestamp: new_timestamp})}
  end
end
