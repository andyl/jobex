defmodule JobexWeb.TimeSec do
  use Phoenix.LiveView
  use Timex

  # to mount in a view:
  # <%= live_render(@conn, JobexWeb.TimeSec) %>

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
    new_date = ldate()
    {:noreply, assign(socket, %{date: new_date})}
  end

  defp ldate do
    Timex.now("US/Pacific")
    |> Timex.format!("%Y %b %d | %H:%M:%S", :strftime)
  end
end
