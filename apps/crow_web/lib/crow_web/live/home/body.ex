defmodule CrowWeb.Live.Home.Body do
  use Phoenix.LiveView

  alias Phoenix.HTML

  def mount(session, socket) do
    CrowWeb.Endpoint.subscribe("uistate")
    CrowWeb.Endpoint.subscribe("job-refresh")
    {:ok, assign(socket, %{uistate: session.uistate, body_data: session.body_data})}
  end

  def render(assigns) do
    ~L"""
    <b><%= hdr_for(@uistate) %></b>
    <small>
    <table class='table table-sm table-bordered'>
      <%= for job <- @body_data do %>
        <tr <%= dstyle(job) |> HTML.raw() %>>
          <td> 
          <a href="/jobs/<%= job.id %>">
          <%= job.id %>
          </a>
          </td>
          <td> 
            <%= tlink(@uistate, "state", job.state) |> HTML.raw() %>
          </td>
          <td>
            <%= tlink(@uistate, "queue", job.queue) |> HTML.raw() %>
          </td>
          <td> 
            <%= tlink(@uistate, "type", job.args["type"]) |> HTML.raw() %>
          </td>
          <td><%= dstart(job) %></td>
          <td align='right'><%= dsecs(@uistate, job) |> HTML.raw() %></td>
          <td><%= dcmd(@uistate, job) |> HTML.raw() %></td>
        </tr>
      <% end %>
    </table>
    </small>
    """
  end

  # ----- view helpers -----
  
  defp tlink(uistate, field, value) do
    if uistate == %{field: field, value: value} do
      "<b>#{value}</b>"
    else
      """
      <a href="#" phx-click="#{field}" phx-value="#{value}">
      #{value}
      </a>
      """
    end
  end

  defp dstyle(job) do
    %{
      "discarded" => "style='background-color: #ffb3a7;'",
      "retryable" => "style='background-color: #ffc673;'",
      "available" => "style='background-color: lightyellow;'",
      "executing" => "style='background-color: #dbfad2;'"
    }[job.state]
  end

  def dstart(job) do
    if job.attempted_at do
      job.attempted_at
      |> Timex.Timezone.convert("PDT")
      |> Timex.Format.DateTime.Formatters.Strftime.format!("%m-%d %H:%M")
    else
      nil
    end
  end

  def esecs(job) do
    DateTime.diff(job.completed_at, job.attempted_at) 
  end

  def dsecs(uistate, job) do
    if job.completed_at do
      secs = DateTime.diff(job.completed_at, job.attempted_at) 
      if secs >= 100 do
        if uistate == %{field: "secs", value: "99+"} do
          "<b>#{secs}</b>"
        else
          "<a href='#' phx-click='secs' phx-value='99+'>#{secs}</a>"
        end
      else
        "#{secs}"
      end
    else
      "NA"
    end
  end

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
      <a href='#' phx-click="command" phx-value="#{cleanword}">#{word}</a>
      """
    end
  end

  # ----- event handlers -----

  def handle_event(label, payload, socket) do
    uistate = %{field: label, value: payload} 
    body_data = CrowData.Query.job_query(uistate)
    opt = %{uistate: uistate, body_data: body_data}

    CrowWeb.Endpoint.broadcast_from(self(), "uistate-table", "table-click", uistate)

    {:noreply, assign(socket, opt)}
  end
  
  # ----- pub/sub handlers -----

  def handle_info(%{topic: "job-refresh"}, socket) do
    uistate = socket.assigns.uistate

    opts = %{
      body_data: CrowData.Query.job_query(uistate)
    }

    {:noreply, assign(socket, opts)}
  end

  def handle_info(broadcast, socket) do
    uistate = broadcast.payload.uistate

    opts =
      if broadcast.payload.uistate do
        %{
          uistate: uistate,
          body_data: CrowData.Query.job_query(uistate)
        }
      else
        %{}
      end

    {:noreply, assign(socket, opts)}
  end

  defp hdr_for(uistate) do
    case uistate do
      %{field: nil, value: nil} -> "ALL JOBS"
      %{field: "all", value: ___} -> "ALL JOBS"
      %{field: fld, value: val} -> "#{fld} / #{val}"
    end
  end
end
