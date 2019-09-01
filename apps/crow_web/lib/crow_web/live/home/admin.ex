defmodule CrowWeb.Live.Home.Body do
  use Phoenix.LiveView

  def mount(_session, socket) do
    CrowWeb.Endpoint.subscribe("uistate")
    CrowWeb.Endpoint.subscribe("job-refresh")
    {:ok, assign(socket, %{uistate: session.uistate, body_data: session.body_data})}
  end

  def render(assigns) do
      ~L"""
      <div class="row">
        <div class="col-md-3" style='border-right: 1px solid lightgray;'>
          <%= live_render(@conn, CrowWeb.Live.Home.Sidebar, session: %{uistate: @uistate, side_data: @side_data}) %>
        </div>

        <div class="col-md-9">
          <%= live_render(@conn, CrowWeb.Live.Home.Body, session: %{uistate: @uistate, body_data: @body_data}) %>
        </div>
    </div>
    """
  end

  def handle_params do
  end
end
