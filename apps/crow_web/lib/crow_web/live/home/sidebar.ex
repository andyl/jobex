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
    <div phx-keydown='keydown' phx-target='window'></div>
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
    <%= raw sidebar_top_lnk(assigns) %>
    <%= raw sidebar_up_lnk(assigns) %>
    <%= raw sidebar_dn_lnk(assigns) %>
    <%= raw sidebar_btm_lnk(assigns) %>
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
    base = [:state_count, :queue_count, :type_count, :alert_count]
    |> Enum.map(&({&1, Map.keys(assigns.sidebar_count[&1])}))
    |> Enum.reduce([], fn({k,v}, acc)-> acc |> Enum.concat(Enum.map(v, &([k, &1]))) end)
    |> Enum.map(fn([k, v])-> [Atom.to_string(k) |> String.replace("_count", ""), v] end)
    [["all", "na"]] ++ base
  end

  def sidebar_top(assigns) do
    assigns
    |> sidebar_pairs()
    |> List.first()
  end

  def sidebar_up(assigns) do
    current = [assigns.uistate.field, assigns.uistate.value]
    pairs = sidebar_pairs(assigns)
    cindx = Enum.find_index(pairs, &(&1 == current))
    nindx = Enum.max([cindx - 1, 0])
    Enum.at(pairs, nindx)
  end

  def sidebar_dn(assigns) do
    current = current_pair(assigns)
    pairs = sidebar_pairs(assigns)
    maxln = Enum.count(pairs) - 1
    cindx = Enum.find_index(pairs, &(&1 == current))
    nindx = Enum.min([cindx + 1, maxln])
    Enum.at(pairs, nindx)
  end

  def sidebar_btm(assigns) do
    assigns
    |> sidebar_pairs()
    |> List.last()
  end

  def sidebar_top_lnk(assigns) do
    new = sidebar_top(assigns)
    old = current_pair(assigns)
    link_for("<i class='fa fa-angle-double-up'></i>", new, new == old)
  end

  def sidebar_up_lnk(assigns) do
    new = sidebar_up(assigns)
    old = current_pair(assigns)
    link_for("<i class='fa fa-angle-up'></i>", new, new == old)
  end

  def sidebar_dn_lnk(assigns) do
    new = sidebar_dn(assigns)
    old = current_pair(assigns)
    link_for("<i class='fa fa-angle-down'></i>", new, new == old)
  end

  def sidebar_btm_lnk(assigns) do
    new = sidebar_btm(assigns)
    old = current_pair(assigns)
    link_for("<i class='fa fa-angle-double-down'></i>", new, new == old)
  end

  def current_pair(assigns) do
    [assigns.uistate.field, assigns.uistate.value]
  end

  def path_for([field, value]), do: "/home?field=#{field}&value=#{value}&page=1"

  def link_for(lbl, [field, value], disabled) do
    distxt = if disabled, do: "disabled", else: ""
    path = path_for([field, value])
    """
    <li class="page-item #{distxt}">
    <a class="page-link" href="#{path}" to="#{path}" data-phx-live-link="push">
    #{lbl}
    </a>
    </li>
    """
  end

  # ----- keyboard event handlers -----

  def handle_event("keydown", "ArrowUp", socket) do
    new = sidebar_up(socket.assigns)
    old = current_pair(socket.assigns)
    if new != old do
      newpath = %{newpath: path_for(new)}
      CrowWeb.Endpoint.broadcast_from(self(), "arrow-key", "page-nav", newpath)
    end
    {:noreply, socket}
  end

  def handle_event("keydown", "ArrowDown", socket) do
    new = sidebar_dn(socket.assigns)
    old = current_pair(socket.assigns)
    if new != old do
      newpath = %{newpath: path_for(new)}
      CrowWeb.Endpoint.broadcast_from(self(), "arrow-key", "page-nav", newpath)
    end
    {:noreply, socket}
  end

  def handle_event("keydown", _alt, socket), do: {:noreply, socket}

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
