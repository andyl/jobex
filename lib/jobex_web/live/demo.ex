defmodule JobexWeb.Live.Demo do
  use JobexWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    :timer.send_interval(10000, self(), :tick)
    {:ok, assign(socket, count: 0, valid_url: false, update_str: "", date: ldate())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h3>LiveView Counter</h3>
    <hr />
    <div>
      <h4>The count is: {@count}</h4>
      <button phx-click="dec">-</button>
      <button phx-click="inc">+</button>
    </div>
    <div class="h-12"></div>
    <h3>LiveView Clock</h3>
    Current time is {@date}
    <div class="h-12"></div>
    <h3>LiveView Text Input</h3>
    <form phx-change="update_string">
      <input type="text" name="str" placeholder="String..." /> {@update_str}
    </form>
    <div class="h-12"></div>
    <h3>LiveView Url Validation</h3>
    <form phx-change="validate_url" phx-submit="save_url">
      <input type="text" name="url" placeholder="URL..." />
      <%= if @valid_url, do: "valid url", else: "invalid url - needs <scheme>://<host>/<path>" %>
    </form>
    """
  end

  # ----- clock

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, update(socket, :date, fn _ -> ldate() end)}
  end

  # ----- counter

  @impl true
  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  @impl true
  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end

  # ----- text input

  @impl true
  def handle_event("update_string", arg, socket) do
    slen = String.length(arg["str"])
    ustr = if slen > 0, do: "length #{slen}", else: ""
    ufun = fn _ -> ustr end
    {:noreply, update(socket, :update_str, ufun)}
  end

  # ----- url validation

  @impl true
  def handle_event("validate_url", arg, socket) do
    {_, boolean_result, _} = validate_url(arg["url"])
    vfun = fn _ -> boolean_result end
    {:noreply, update(socket, :valid_url, vfun)}
  end

  @impl true
  def handle_event("save_url", _params, socket) do
    {:noreply, socket}
  end

  # ----- misc

  defp ldate do
    DateTime.utc_now()
    |> DateTime.shift_zone!("America/Los_Angeles")
    |> Calendar.strftime("%d %b %H:%M")
  end

  defp validate_url(str) do
    uri = URI.parse(str)

    case uri do
      %URI{scheme: nil} -> {:error, false, uri}
      %URI{host: nil} -> {:error, false, uri}
      %URI{path: nil} -> {:error, false, uri}
      uri -> {:ok, true, uri}
    end
  end
end
