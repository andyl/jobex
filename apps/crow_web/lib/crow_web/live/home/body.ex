defmodule CrowWeb.Live.Home.Body do
  use Phoenix.LiveView

  import Phoenix.HTML

  alias CrowWeb.Util
  alias Phoenix.HTML.SimplifiedHelpers.Truncate

  def mount(session, socket) do
    CrowWeb.Endpoint.subscribe("job-refresh")
    job_count = job_count(session.uistate)
    uistate = session.uistate

    opts = %{
      body_data: CrowData.Query.job_data(uistate),
      uistate: uistate,
      job_count: job_count,
      num_pages: num_pages(job_count),
    }
    {:ok, assign(socket, opts)}
  end

  def render(assigns) do
    ~L"""
    <div class='row'>
    <div class='col-md-6'>
    <b><%= hdr_for(@uistate) %></b>
    </div> 
    <div class='col-md-6 text-right'>
    <%= live_render(@socket, CrowWeb.TimeSec) %>
    </div>
    </div>
    <small>
    <table class='table table-sm table-bordered' phx-keydown='keydown' phx-target='window' style='margin-bottom: 30px;'>
      <%= for job <- @body_data do %>
        <tr <%= raw dstyle(job) %>>
          <td> 
          <a href="/jobs/<%= job.id %>">
          <%= job.id %>
          </a>
          </td>
          <td> 
            <%= raw tlink(@uistate, "state", job.state) %>
          </td>
          <td>
            <%= raw tlink(@uistate, "queue", job.queue) %>
          </td>
          <td> 
            <%= raw tlink(@uistate, "type", job.args["type"]) %>
          </td>
          <td><%= dstart(job) %></td>
          <td align='right'><%= raw dsecs(@uistate, job) %></td>
          <td><%= raw dcmd(@uistate, job) %></td>
        </tr>
      <% end %>
    </table>
    <nav area-label="pagination">
    <ul class="pagination justify-content-center">
    <%= raw prev_links(assigns) %>
    <li class="page-item disabled">
    <a class="page-link" href='#'>page <%= pg_msg(@uistate.page, @num_pages) %></a>
    </li>
    <%= raw next_links(assigns) %>
    </ul>
    </nav>
    </small>
    """
  end

  # ----- event handlers -----
  
  defp path_for(uistate) do
    "/home?field=#{uistate.field}&value=#{uistate.value}&page=#{uistate.page}"
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
    my_live_link("<<", path_for(newstate))
  end

  def page_link_for("page_dec", assigns) do
    oldpage = assigns.uistate.page
    newpage = Enum.max([oldpage - 1, 1])
    newstate = Map.merge(assigns.uistate, %{page: newpage})
    my_live_link("<", path_for(newstate))
  end

  def page_link_for("page_inc", assigns) do
    num_pages = assigns.num_pages
    oldpage   = assigns.uistate.page 
    newpage   = Enum.min([oldpage + 1, num_pages])
    newstate  = Map.merge(assigns.uistate, %{page: newpage})
    my_live_link(">", path_for(newstate))
  end

  def page_link_for("page_max", assigns) do
    num_pages = assigns.num_pages
    newstate = Map.merge(assigns.uistate, %{page: num_pages})
    my_live_link(">>", path_for(newstate))
  end

  def handle_event("keydown", "ArrowLeft", socket) do
    oldpage = socket.assigns.uistate.page
    newpage = Enum.max([oldpage - 1, 1])
    newstate = Map.merge(socket.assigns.uistate, %{page: newpage})
    {:noreply, live_redirect(socket, path_for(newstate))}
  end

  def handle_event("keydown", "ArrowRight", socket) do
    handle_event("page_dec", "na", socket)
  end

  def handle_event("keydown", _alt, socket) do
    {:noreply, socket}
  end

  # ----- table header

  defp hdr_for(uistate) do
    case uistate do
      %{field: nil, value: nil} -> "ALL JOBS"
      %{field: "all", value: _} -> "ALL JOBS"
      %{field: fld, value: val} -> "#{fld} / #{val}"
    end
  end
  
  # ----- row style 

  defp dstyle(job) do
    %{
      "discarded" => "style='background-color: #ffb3a7;'",
      "retryable" => "style='background-color: #ffc673;'",
      "available" => "style='background-color: lightyellow;'",
      "executing" => "style='background-color: #dbfad2;'"
    }[job.state]
  end

  # ----- table link
  
  defp tlink(uistate, field, value) do
    if uistate == %{field: field, value: value} do
      "<b>#{value}</b>"
    else
      """
      <a href="/home?field=#{field}&value=#{value}">
      #{value}
      </a>
      """
    end
  end

  # ----- start time

  def dstart(job) do
    if job.attempted_at do
      job.attempted_at
      |> Timex.Timezone.convert("PDT")
      |> Timex.Format.DateTime.Formatters.Strftime.format!("%m-%d %H:%M")
    else
      nil
    end
  end

  # ----- elapsed seconds

  def esecs(job) do
    DateTime.diff(job.completed_at, job.attempted_at) 
  end

  def dsecs(uistate, job) do
    if job.completed_at do
      secs = esecs(job)
      if secs >= 100 do
        if uistate == %{field: "alert", value: "speed"} do
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

  # ----- paging
  
  defp pg_msg(page, num_pages) do
    numpg = if num_pages == 0, do: 0, else: page
    "#{numpg} of #{num_pages}"
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

  defp prev_links(assigns) do
    if assigns.uistate.page == 1 || assigns.num_pages == 0 do
    """
    <li class="page-item disabled"><a class="page-link" href='#'><<</a></li>
    <li class="page-item disabled"><a class="page-link" href='#'><</a></li>
    """
    else
    """
    #{page_link_for("page_min", assigns)}
    #{page_link_for("page_dec", assigns)}
    """
    end
  end

  defp next_links(assigns) do
    if assigns.uistate.page == assigns.num_pages || assigns.num_pages == 0 do
    """
    <li class="page-item disabled"><a class="page-link" href='#'>></a></li>
    <li class="page-item disabled"><a class="page-link" href='#'>>></a></li>
    """
    else
    """
    #{page_link_for("page_inc", assigns)}
    #{page_link_for("page_max", assigns)}
    """
    end
  end

  # ----- commands

  defp dcmd(uistate, job) do
    job.args["cmd"]
    |> HTML.SimplifiedHelpers.Truncate.truncate(length: 22)
    |> String.split(" ")
    |> Enum.map(&(cmd_link(uistate, &1)))
    |> Enum.join(" ")
  end

  defp cmd_link(uistate, word) do
    cleanword =
      word
      |> String.replace("...", "")
    if uistate == %{field: "command", value: cleanword} do
      "<b>#{word}</b>"
    else
      """
      <a href='/home?field=command&value=#{cleanword}'>#{word}</a>
      """
    end
  end
  
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

end
