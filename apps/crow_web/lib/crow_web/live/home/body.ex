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
    <table class='table table-sm'>
      <%= for job <- @body_data do %>
        <tr>
          <td> <%= job.id %> </td>
          <td> <%= job.state %> </td>
          <td> <%= job.args["type"] %> </td>
          <td> <%= dstart(job) %> </td>
          <td> <%= dsecs(job) %>
          <td> <%= dstdout(job) %>
        </tr>
      <% end %>
    </table>
    </small>
    """
  end

  defp dstart(job) do
    if job.attempted_at do
      job.attempted_at
      |> Timex.Format.DateTime.Formatters.Strftime.format!("%m-%d %H:%M:%S")
    else
      nil
    end
  end

  defp dsecs(job) do
    if job.completed_at do
      DateTime.diff(job.completed_at, job.attempted_at) 
    else
      "NA"
    end
  end

  defp dstdout(job) do
    if job.results != [] do
      job.results
      |> List.first()
      |> Map.get(:stdout)
      |> Phoenix.HTML.SimplifiedHelpers.Truncate.truncate(length: 22)
    else
      ""
    end
  end

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
      %{field: nil, value: nil} -> "LATEST JOBS"
      %{field: "all", value: ___} -> "LATEST JOBS"
      %{field: fld, value: val} -> "#{fld} / #{val}"
    end
  end
end
