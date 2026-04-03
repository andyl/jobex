defmodule JobexWeb.Live.Home.Sidebar do
  use JobexWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    :timer.send_interval(5000, self(), :sidebar_tick)
    JobexWeb.Endpoint.subscribe("job-event")
    sidebar_count = JobexCore.Query.sidebar_count()

    opts = %{refresh: false, uistate: session["uistate"], sidebar_count: sidebar_count}
    {:ok, assign(socket, opts)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-keydown="keydown" phx-target="window">
    </div>
    <div>
      <%= if @uistate.field == "all" || @uistate.value == nil do %>
        <span class="sidebar-active">&gt; <b>ALL ({@sidebar_count.all_count})</b></span>
      <% else %>
        <a href="/home"><b>ALL ({@sidebar_count.all_count})</b></a>
      <% end %>
    </div>
    <hr class="my-2" />
    <b>States</b>
    <ul class="menu menu-xs pl-2">
      <%= for {key, val} <- @sidebar_count.state_count do %>
        <li>
          <.sidebar_link uistate={@uistate} field="state" value={key} label={"#{key} (#{val})"} />
        </li>
      <% end %>
    </ul>
    <hr class="my-2" />
    <b>Queues</b>
    <ul class="menu menu-xs pl-2">
      <%= for {key, val} <- @sidebar_count.queue_count do %>
        <li>
          <.sidebar_link uistate={@uistate} field="queue" value={key} label={"#{key} (#{val})"} />
        </li>
      <% end %>
    </ul>
    <hr class="my-2" />
    <b>Types</b>
    <ul class="menu menu-xs pl-2">
      <%= for {key, val} <- @sidebar_count.type_count do %>
        <li>
          <.sidebar_link uistate={@uistate} field="type" value={key} label={"#{key} (#{val})"} />
        </li>
      <% end %>
    </ul>
    <hr class="my-2" />
    <b>Alerts</b>
    <ul class="menu menu-xs pl-2">
      <%= for {key, val} <- @sidebar_count.alert_count do %>
        <li>
          <.sidebar_link uistate={@uistate} field="alert" value={key} label={"#{key} (#{val})"} />
        </li>
      <% end %>
    </ul>
    <nav class="pt-6">
      <div class="join">
        <.page_btn disabled={nav_disabled?(assigns, "top")} path={nav_path(assigns, "top")} icon="fa-angle-double-up" />
        <.page_btn disabled={nav_disabled?(assigns, "up")} path={nav_path(assigns, "up")} icon="fa-angle-up" />
        <.page_btn disabled={nav_disabled?(assigns, "dn")} path={nav_path(assigns, "dn")} icon="fa-angle-down" />
        <.page_btn disabled={nav_disabled?(assigns, "btm")} path={nav_path(assigns, "btm")} icon="fa-angle-double-down" />
      </div>
    </nav>
    """
  end

  attr :uistate, :map, required: true
  attr :field, :string, required: true
  attr :value, :string, required: true
  attr :label, :string, required: true

  defp sidebar_link(assigns) do
    active = assigns.uistate.field == assigns.field && assigns.uistate.value == assigns.value
    path = "/home?field=#{assigns.field}&value=#{assigns.value}&page=1"
    assigns = assign(assigns, active: active, path: path)

    ~H"""
    <%= if @active do %>
      <span class="sidebar-active">&gt; {@label}</span>
    <% else %>
      <a href={@path} data-phx-link="patch" data-phx-link-state="push">{@label}</a>
    <% end %>
    """
  end

  attr :disabled, :boolean, required: true
  attr :path, :string, required: true
  attr :icon, :string, required: true

  defp page_btn(assigns) do
    ~H"""
    <%= if @disabled do %>
      <button class="btn btn-xs join-item btn-disabled">
        <i class={"fa #{@icon}"}></i>
      </button>
    <% else %>
      <a href={@path} data-phx-link="patch" data-phx-link-state="push" class="btn btn-xs join-item">
        <i class={"fa #{@icon}"}></i>
      </a>
    <% end %>
    """
  end

  defp nav_target(assigns, "top"), do: sidebar_top(assigns)
  defp nav_target(assigns, "up"), do: sidebar_up(assigns)
  defp nav_target(assigns, "dn"), do: sidebar_dn(assigns)
  defp nav_target(assigns, "btm"), do: sidebar_btm(assigns)

  defp nav_disabled?(assigns, action), do: nav_target(assigns, action) == current_pair(assigns)
  defp nav_path(assigns, action), do: path_for(nav_target(assigns, action))

  # ----- navigation helpers -----

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

  def sidebar_top(assigns), do: sidebar_pairs(assigns) |> List.first()

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

  def sidebar_btm(assigns), do: sidebar_pairs(assigns) |> List.last()

  def current_pair(assigns), do: [assigns.uistate.field, assigns.uistate.value]

  def path_for([field, value]), do: "/home?field=#{field}&value=#{value}&page=1"

  # ----- keyboard event handlers -----

  @impl true
  def handle_event("keydown", key = %{"key" => "ArrowUp"}, socket) do
    new = if key["ctrlKey"], do: sidebar_top(socket.assigns), else: sidebar_up(socket.assigns)
    old = current_pair(socket.assigns)

    if new != old do
      newpath = %{newpath: path_for(new)}
      JobexWeb.Endpoint.broadcast_from(self(), "arrow-key", "page-nav", newpath)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("keydown", key = %{"key" => "ArrowDown"}, socket) do
    new = if key["ctrlKey"], do: sidebar_btm(socket.assigns), else: sidebar_dn(socket.assigns)
    old = current_pair(socket.assigns)

    if new != old do
      newpath = %{newpath: path_for(new)}
      JobexWeb.Endpoint.broadcast_from(self(), "arrow-key", "page-nav", newpath)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("keydown", _alt, socket), do: {:noreply, socket}

  # ----- pub-sub handlers -----

  @impl true
  def handle_info(%{topic: "job-event"}, socket) do
    {:noreply, assign(socket, %{refresh: true})}
  end

  @impl true
  def handle_info(:sidebar_tick, socket) do
    opts =
      if socket.assigns.refresh do
        JobexWeb.Endpoint.broadcast_from(self(), "job-refresh", "sidebar-tick", %{})

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
