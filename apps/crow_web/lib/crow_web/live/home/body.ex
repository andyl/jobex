defmodule CrowWeb.Live.Home.Body do
  use Phoenix.LiveView

  import Phoenix.HTML

  alias CrowWeb.Util

  def mount(session, socket) do
    CrowWeb.Endpoint.subscribe("job-refresh")
    CrowWeb.Endpoint.subscribe("time-tick")
    job_count = job_count(session.uistate)
    uistate = session.uistate

    opts = %{
      body_data: CrowData.Query.job_data(uistate),
      uistate:   uistate,
      job_count: job_count,
      num_pages: num_pages(job_count),
      timestamp: hdr_timestamp()
    }
    {:ok, assign(socket, opts)}
  end

  def render(assigns) do
    ~L"""
    <div class='row' phx-keydown='keydown' phx-target='window'>
    <div class='col-md-6'>
    <b><%= page_hdr_for(@uistate) %></b>
    </div> 
    <div class='col-md-6 text-right'>
    <%= @timestamp %>
    </div>
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
    Timex.now("US/Pacific")
    |> Timex.format!("%Y %b %d | %H:%M:%S", :strftime)
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
      job.attempted_at
      |> Timex.Timezone.convert("PDT")
      |> Timex.Format.DateTime.Formatters.Strftime.format!("%m-%d %H:%M")
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
    |> String.split(" ")
    |> Enum.map(&(cmd_link(uistate, &1)))
    |> Enum.join(" ")
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
      nil       -> CrowData.Query.all_count()
      "all"     -> CrowData.Query.all_count()
      "state"   -> CrowData.Query.state_count()[uistate.value]
      "type"    -> CrowData.Query.type_count()[uistate.value]
      "queue"   -> CrowData.Query.queue_count()[uistate.value]
      "command" -> CrowData.Query.command_count(uistate.value)[uistate.value]
      "alert"   -> CrowData.Query.alert_count()[uistate.value]
      _         -> CrowData.Query.all_count()
    end
  end

  defp num_pages(job_count) do
    if job_count > 0 do
      size = CrowData.Query.page_size()
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

  # ----- keyboard event handlers -----

  def handle_event("keydown", keypress = %{"key" => "ArrowLeft"}, socket) do
    oldpage = socket.assigns.uistate[:page] || 1
    newpage = if keypress["ctrlKey"], do: 1, else: Enum.max([oldpage - 1, 1])
    newstate = Map.merge(socket.assigns.uistate, %{page: newpage})
    newpath   = %{newpath: path_for(newstate)}
    if newpage != oldpage do
      CrowWeb.Endpoint.broadcast_from(self(), "arrow-key", "page-nav", newpath)
    end
    {:noreply, socket}
  end

  def handle_event("keydown", keypress = %{"key" => "ArrowRight"}, socket) do
    num_pages = socket.assigns.num_pages
    oldpage   = socket.assigns.uistate[:page] || 1
    newpage   = if keypress["ctrlKey"], do: num_pages, else: Enum.min([oldpage + 1, num_pages])
    newstate  = Map.merge(socket.assigns.uistate, %{page: newpage})
    newpath   = %{newpath: path_for(newstate)}
    if newpage != oldpage do
      CrowWeb.Endpoint.broadcast_from(self(), "arrow-key", "page-nav", newpath)
    end
    {:noreply, socket}
  end

  def handle_event("keydown", _alt, socket), do: {:noreply, socket}
  
  # ----- pub/sub handlers -----

  def handle_info(%{topic: "job-refresh"}, socket) do
    uistate = socket.assigns.uistate
    job_count = job_count(uistate)

    opts = %{
      body_data: CrowData.Query.job_data(uistate),
      job_count: job_count,
      num_pages: num_pages(job_count)
    }

    {:noreply, assign(socket, opts)}
  end

  def handle_info(%{topic: "time-tick"}, socket) do
    new_timestamp = hdr_timestamp()
    {:noreply, assign(socket, %{timestamp: new_timestamp})}
  end
end
