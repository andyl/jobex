defmodule CrowWeb.Live.Home.Sidebar do
  use Phoenix.LiveView

  import Phoenix.HTML

  def mount(session, socket) do
    :timer.send_interval(5000, self(), :sidebar_tick)
    CrowWeb.Endpoint.subscribe("job-event")
    sidebar_count = CrowData.Query.sidebar_count()
    opts = %{refresh: false, uistate: session.uistate, sidebar_count: sidebar_count}
    {:ok, assign(socket, opts)}
  end

  def render(assigns) do
    ~L"""
    <%= raw all_for(@uistate, @sidebar_count) %>
    <hr/>
    <b>States</b>
    <small>
    <ul class="nav flex-column">
      <%= for {key, val} <- @sidebar_count.state_count do %>
        <%= raw link_for(@uistate, "state", key, "#{key} (#{val})") %>
      <% end %>
    </ul>
    </small>
    <hr/>
    <b>Queues</b>
    <small>
    <ul class="nav flex-column">
      <%= for {key, val} <- @sidebar_count.queue_count do %>
        <%= raw link_for(@uistate, "queue", key, "#{key} (#{val})") %>
      <% end %>
    </ul>
    </small>
    <hr/>
    <b>Types</b>
    <small>
    <ul class="nav flex-column">
      <%= for {key, val} <- @sidebar_count.type_count do %>
        <%= raw link_for(@uistate, "type", key, "#{key} (#{val})") %>
      <% end %>
    </ul>
    </small>
    <hr/>
    <b>Alerts</b>
    <small>
    <ul class="nav flex-column">
      <%= for {key, val} <- @sidebar_count.alert_count do %>
        <%= raw link_for(@uistate, "alert", key, "#{key} (#{val})") %>
      <% end %>
    </ul>
    <nav area-label="pagination" style='padding-top: 30px;'>
    <ul class="pagination justify-content-center">
    <li class="page-item">
    <a class="page-link" href='#'><i class='fa fa-angle-double-up'></i></a>
    </li>
    <li class="page-item">
    <a class="page-link" href='#'><i class='fa fa-angle-up'></i></a>
    </li>
    <li class="page-item">
    <a class="page-link" href='#'><i class='fa fa-angle-down'></i></a>
    </li>
    <li class="page-item">
    <a class="page-link" href='#'><i class='fa fa-angle-double-down'></i></a>
    </li>
    </ul>
    </nav>
    </small>
    """
  end

  # ----- view helpers -----

  defp link_for(uistate, field, value, text) do
    path = "/home?field=#{field}&value=#{value}&page=1"
    {ldr, klas} = if [uistate.field, uistate.value] == [field, value], do: {">", "disabled"}, else: {"", ""}

    """
    <li class="nav-item">
      <a href="#{path}" to="#{path}" data-phx-live-link="push" class="nav-link #{klas}" style="padding-top: .1rem; padding-bottom: .1rem;">
        #{ldr} #{text}
      </a>
    </li>
    """
  end

  defp all_for(uistate, sidebar_count) do
    text = "<b>ALL (#{sidebar_count.all_count})</b>"

    if uistate.field == "all" || uistate.value == nil do
      "<span style='color: gray;'>> #{text}</span>"
    else
      """
      <a href="/home">
        #{text}
      </a>
      """
    end
  end

  # ----- navigation helpers -----

  def sidebar_pairs(assigns) do
    counts = Map.drop(assigns.sidebar_count, [:all_count])
  end

  def sidebar_next(assigns, current) do
  end

  def sidebar_prev(assigns, current) do
  end

  def sidebar_top(assigns) do
  end

  def sidebar_up(assigns) do
  end

  def sidebar_dn(assigns) do
  end

  def sidebar_btm(assigns) do
  end

  def sidebar_top_lnk(assigns) do
  end

  def sidebar_up_lnk(assigns) do
  end

  def sidebar_dn_lnk(assigns) do
  end

  def sidebar_btm_lnk(assigns) do
  end

  # ----- pub-sub handlers -----

  # set refresh to true whenever a job starts or stops
  # this could be triggered many times within a five-second window
  def handle_info(%{topic: "job-event"}, socket) do
    {:noreply, assign(socket, %{refresh: true})}
  end
  
  # this callback is triggered every five seconds.
  # when refresh is set to true, update the sidebar count
  # in this way, we batch updates in order to minimize UI flickering and rapid DB hits
  def handle_info(:sidebar_tick, socket) do
    opts =
      if socket.assigns.refresh do
        CrowWeb.Endpoint.broadcast_from(self(), "job-refresh", "sidebar-tick", %{})
        %{
          refresh: false,
          sidebar_count: CrowData.Query.sidebar_count()
        }
      else
        %{}
      end

    {:noreply, assign(socket, opts)}
  end
end
