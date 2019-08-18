defmodule CrowWeb.TimeLcl do
  use Phoenix.LiveView
  use Timex

  def render(assigns) do
    ~L"""
    <%= @date %>
    """
  end

  def mount(_session, socket) do
    :timer.send_interval(10000, self(), :tick)
    {:ok, assign(socket, date: ldate())}
  end

  def handle_info(:tick, socket) do
    {:noreply, update(socket, :date, fn (_) -> ldate() end)}
  end

  defp ldate do
    Timex.now("US/Pacific")
    |> Timex.format!("%d %b %H:%M", :strftime)
  end
end
