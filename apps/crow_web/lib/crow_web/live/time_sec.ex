defmodule CrowWeb.TimeSec do
  use Phoenix.LiveView
  use Timex

  # to mount in a view:
  # <%= live_render(@conn, CrowWeb.TimeSec) %>

  def render(assigns) do
    ~L"""
    <%= @date %>
    """
  end

  def mount(_session, socket) do
    :timer.send_interval(1000, self(), :tick)
    {:ok, assign(socket, date: ldate())}
  end

  def handle_info(:tick, socket) do
    {:noreply, update(socket, :date, fn (_) -> ldate() end)}
  end

  defp ldate do
    Timex.now("US/Pacific")
    |> Timex.format!("%Y %b %d | %H:%M:%S", :strftime)
  end
end
