defmodule CrowWeb.Live.Home.Sidebar do
  use Phoenix.LiveView

  import Phoenix.HTML

  alias CrowWeb.Router.Helpers, as: Routes

  def mount(session, socket) do
    :timer.send_interval(5000, self(), :sidebar_tick)
    CrowWeb.Endpoint.subscribe("job-event")
    opts = %{refresh: false, uistate: session.uistate, side_data: session.side_data}
    {:ok, assign(socket, opts)}
  end

  def render(assigns) do
    ~L"""
    <%= raw all_for(@uistate, @side_data) %>
    <hr/>
    <b>States</b>
    <small>
    <ul class="nav flex-column">
      <%= for {key, val} <- @side_data.job_states do %>
        <%= raw link_for(@uistate, "state", key, "#{key} (#{val})") %>
      <% end %>
    </ul>
    </small>
    <hr/>
    <b>Queues</b>
    <small>
    <ul class="nav flex-column">
      <%= for {key, val} <- @side_data.job_queues do %>
        <%= raw link_for(@uistate, "queue", key, "#{key} (#{val})") %>
      <% end %>
    </ul>
    </small>
    <hr/>
    <b>Types</b>
    <small>
    <ul class="nav flex-column">
      <%= for {key, val} <- @side_data.job_types do %>
        <%= raw link_for(@uistate, "type", key, "#{key} (#{val})") %>
      <% end %>
    </ul>
    </small>
    <hr/>
    <b>Alerts</b>
    <small>
    <ul class="nav flex-column">
      <%= for {key, val} <- @side_data.job_alerts do %>
        <%= raw link_for(@uistate, "alerts", key, "#{key} (#{val})") %>
      <% end %>
    </ul>
    </small>
    """
  end

  # ----- view helpers -----

  defp link_for(uistate, field, value, text) do
    path = "/home?field=#{field}&value=#{value}"
    {ldr, klas} = if uistate == %{field: field, value: value}, do: {">", "disabled"}, else: {"", ""}

    """
    <li class="nav-item">
      <a href="#{path}" to="#{path}" data-phx-live-link="push" class="nav-link #{klas}" style="padding-top: .1rem; padding-bottom: .1rem;">
        #{ldr} #{text}
      </a>
    </li>
    """
  end

  defp all_for(uistate, side_data) do
    text = "<b>ALL (#{side_data.all_count})</b>"

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

  # ----- pub-sub handlers -----

  def handle_info(:sidebar_tick, socket) do
    opts =
      if socket.assigns.refresh do
        CrowWeb.Endpoint.broadcast_from(self(), "job-refresh", "sidebar-tick", %{})
        %{
          refresh: false,
          side_data: CrowData.Query.side_data()
        }
      else
        %{}
      end

    {:noreply, assign(socket, opts)}
  end

  def handle_info(%{topic: "job-event"}, socket) do
    {:noreply, assign(socket, %{refresh: true})}
  end
end
