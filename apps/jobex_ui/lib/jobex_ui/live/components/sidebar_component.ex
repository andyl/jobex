defmodule JobexUi.SidebarComponent do

  use Phoenix.LiveComponent

  import Phoenix.HTML

  # ----- lifecycle callbacks -----

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(session, socket) do
    IO.inspect session, label: "SIDEBAR SESSION"
    # :timer.send_interval(5000, self(), :sidebar_tick)
    # JobexUi.Endpoint.subscribe("job-event")
    iopts = session.session["opts"]
    xopts = %{
      refresh: false, 
      sidebar_count: JobexCore.Query.sidebar_count(), 
      uistate: iopts.uistate
    }

    {:ok, assign(socket, xopts)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div>
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
      </hr>
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
    </div>
    """
  end

  # ----- view helpers -----

  defp link_for(uistate, field, value, text) do
    path = "/home?field=#{field}&value=#{value}&page=1"

    {ldr, klas} =
      if [uistate.field, uistate.value] == [field, value], do: {">", "disabled"}, else: {"", ""}

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

  # ----- view helpers -----

  def sidebar_pairs(assigns) do
    base =
      if assigns.sidebar_count.all_count != 0 do
        [:state_count, :queue_count, :type_count, :alert_count]
        |> Enum.map(&{&1, Map.keys(assigns.sidebar_count[&1])})
        |> Enum.reduce([], fn {k, v}, acc -> acc |> Enum.concat(Enum.map(v, &[k, &1])) end)
        |> Enum.map(fn [k, v] -> [Atom.to_string(k) |> String.replace("_count", ""), v] end)
      else
        []
      end

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
    cindx = Enum.find_index(pairs, &(&1 == current)) || 0
    nindx = Enum.max([cindx - 1, 0])
    Enum.at(pairs, nindx)
  end

  def sidebar_dn(assigns) do
    current = current_pair(assigns)
    pairs = sidebar_pairs(assigns)
    maxln = Enum.count(pairs) - 1
    cindx = Enum.find_index(pairs, &(&1 == current)) || 0
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
    link_for("<i class='bi-chevron-double-up'></i>", new, new == old)
  end

  def sidebar_up_lnk(assigns) do
    new = sidebar_up(assigns)
    old = current_pair(assigns)
    link_for("<i class='bi-chevron-up'></i>", new, new == old)
  end

  def sidebar_dn_lnk(assigns) do
    new = sidebar_dn(assigns)
    old = current_pair(assigns)
    link_for("<i class='bi-chevron-down'></i>", new, new == old)
  end

  def sidebar_btm_lnk(assigns) do
    new = sidebar_btm(assigns)
    old = current_pair(assigns)
    link_for("<i class='bi-chevron-double-down'></i>", new, new == old)
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

  # ----- event handlers -----

  def handle_event("keydown", key = %{"key" => "ArrowUp"}, socket) do
    new = if key["ctrlKey"], do: sidebar_top(socket.assigns), else: sidebar_up(socket.assigns)
    old = current_pair(socket.assigns)

    if new != old do
      newpath = %{newpath: path_for(new)}
      JobexUi.Endpoint.broadcast_from(self(), "arrow-key", "page-nav", newpath)
    end

    {:noreply, socket}
  end

  def handle_event("keydown", key = %{"key" => "ArrowDown"}, socket) do
    new = if key["ctrlKey"], do: sidebar_btm(socket.assigns), else: sidebar_dn(socket.assigns)
    old = current_pair(socket.assigns)

    if new != old do
      newpath = %{newpath: path_for(new)}
      JobexUi.Endpoint.broadcast_from(self(), "arrow-key", "page-nav", newpath)
    end

    {:noreply, socket}
  end

  def handle_event("keydown", _alt, socket), do: {:noreply, socket}

  # ----- message handlers -----

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
        JobexUi.Endpoint.broadcast_from(self(), "job-refresh", "sidebar-tick", %{})

        %{
          refresh: false,
          sidebar_count: JobexCore.Query.sidebar_count()
        }
      else
        %{}
      end

    {:noreply, assign(socket, opts)}
  end
end
