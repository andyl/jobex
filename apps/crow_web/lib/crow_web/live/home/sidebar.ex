defmodule CrowWeb.Live.Home.Sidebar do
  use Phoenix.LiveView

  import Phoenix.HTML

  def mount(session, socket) do
    {:ok, assign(socket, %{uistate: session.uistate, side_data: session.side_data})}
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
    """
  end

  # ----- view helpers -----

  defp all_for(uistate, side_data) do
    text = "<b>ALL (#{side_data.all_count})</b>"
    if uistate.value == nil do
        "<span style='color: gray;'>> #{text}</span>"
    else
      """
      <a href="#" phx-click="all">
        #{text}
      </a>
      """
    end
  end

  defp link_for(uistate, field, value, text) do
    link = if uistate == %{field: field, value: value} do
      """
      <a href="#" class="nav-link disabled">
        > #{text}
      </a>
      """
    else
      """
      <a href="#" phx-click="#{field}" phx-value="#{value}" class="nav-link">
        #{text}
      </a>
      """
    end

    """
    <li class="nav-item">
      #{link}
    </li>
    """
  end

  # ----- event handlers -----

  def handle_event(label, payload, socket) do
    pload = if label == "all", do: nil, else: payload 
    %{field: label, value: pload}
    |> gen_handle(socket)
  end

  defp gen_handle(uistate, socket) do
    opts = %{
      uistate: uistate,
      side_data: CrowData.Query.side_data()
    }
    CrowWeb.Endpoint.broadcast_from(self(), "uistate", "side-click", %{uistate: uistate})
    {:noreply, assign(socket, opts)}
  end
end
