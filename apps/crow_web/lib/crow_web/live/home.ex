defmodule CrowWeb.Live.Home do
  use Phoenix.LiveView

  alias CrowWeb.Router.Helpers, as: Routes

  def mount(_session, socket) do
    # CrowWeb.Endpoint.subscribe("uistate")
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="row">
      <div class="col-md-3" style='border-right: 1px solid lightgray;'>
        <%= live_render(@socket, CrowWeb.Live.Home.Sidebar, session: %{uistate: @uistate, side_data: @side_data}) %>
      </div>
      <div class="col-md-9">
        <%= live_render(@socket, CrowWeb.Live.Home.Body, session: %{uistate: @uistate, body_data: @body_data}) %>
      </div>
    </div>
    """
  end

  # ----- params handlers -----

  def handle_params(%{"field" => field, "value" => value}, _url, socket) do
    uistate = %{field: field, value: value}
    opts = %{
      body_data: CrowData.Query.job_query(uistate),
      side_data: CrowData.Query.side_data(),
      uistate: uistate 
    }

    {:noreply, assign(socket, opts)}
  end

  def handle_params(_, _, socket) do
    opts = %{
      body_data: CrowData.Query.job_query(),
      side_data: CrowData.Query.side_data(),
      uistate: %{field: nil, value: nil}
    }

    {:noreply, assign(socket, opts)}
  end
  
  # ----- pub-sub handlers -----

  # def handle_info(broadcast, socket) do
  #   uistate = broadcast.payload.uistate
  #
  #   IO.inspect "======================================="
  #   IO.inspect uistate
  #   IO.inspect "======================================="
  #
  #   path = Routes.live_path(socket, CrowWeb.Live.Home, uistate)
  #   {:noreply, live_redirect(socket, to: path)}
  # end
end
