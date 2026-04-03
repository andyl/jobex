defmodule JobexWeb.TimeSec do
  use Phoenix.LiveView

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
    DateTime.utc_now()
    |> DateTime.shift_zone!("US/Pacific")
    |> Calendar.strftime("%Y %b %d | %H:%M:%S")
  end
end
