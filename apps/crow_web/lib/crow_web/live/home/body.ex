defmodule CrowWeb.Live.Home.Body do
  use Phoenix.LiveView

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
        <tr <%= dstyle(job) |> Phoenix.HTML.raw() %>>
          <td> 
          <a href="/jobs/<%= job.id %>">
          <%= job.id %>
          </a>
          </td>
          <td> <%= job.state %> </td>
          <td> <%= job.queue %> </td>
          <td> <%= job.args["type"] %> </td>
          <td> <%= dstart(job) %> </td>
          <td align='right'> <%= dsecs(job) %>
          <td> <%= dcmd(job) %>
        </tr>
      <% end %>
    </table>
    </small>
    """
  end

  defp dstyle(job) do
    %{
      "executing" => "style='background-color: #dbfad2;'",
      "available" => "style='background-color: lightyellow;'"
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

  def dsecs(job) do
    if job.completed_at do
      DateTime.diff(job.completed_at, job.attempted_at) 
    else
      "NA"
    end
  end

  defp dcmd(job) do
    job.args["cmd"]
    |> Phoenix.HTML.SimplifiedHelpers.Truncate.truncate(length: 22)
  end

  # defp dstdout(job) do
  #   if job.results != [] do
  #     job.results
  #     |> List.first()
  #     |> Map.get(:stdout)
  #     |> Phoenix.HTML.SimplifiedHelpers.Truncate.truncate(length: 22)
  #   else
  #     ""
  #   end
  # end

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
