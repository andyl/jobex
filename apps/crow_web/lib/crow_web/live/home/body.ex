defmodule CrowWeb.Live.Home.Body do
  use Phoenix.LiveView

  def mount(session, socket) do
    CrowWeb.Endpoint.subscribe("uistate")
    {:ok, assign(socket, %{uistate: session.uistate, body_data: session.body_data})}
  end

  def render(assigns) do
    ~L"""
    <b><%= hdr_for(@uistate) %></b>
    <table class='table table-sm'>
      <%= for job <- @body_data do %>
        <tr>
          <td> <%= job["type"] %> </td>
          <td> <%= job["jobid"] %> </td>
          <td> <%= job["stdout"] %> </td>
        </tr>
      <% end %>
    </table>
    """
  end

  def handle_info(broadcast, socket) do
    uistate = broadcast.payload.uistate
    opts = %{
      uistate: uistate,
      body_data: CrowData.Query.job_query(uistate)
    }
    {:noreply, assign(socket, opts)}
  end

  defp hdr_for(uistate) do
    case uistate do
      %{field: nil,   value: nil} -> "LATEST JOBS"
      %{field: "all", value: ___} -> "LATEST JOBS"
      %{field: fld, value: val}   -> "#{fld} / #{val}"
    end
  end
end
