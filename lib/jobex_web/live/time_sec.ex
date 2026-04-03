defmodule JobexWeb.TimeSec do
  use JobexWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    :timer.send_interval(1000, self(), :tick)
    {:ok, assign(socket, date: ldate())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    {@date}
    """
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, assign(socket, %{date: ldate()})}
  end

  defp ldate do
    DateTime.utc_now()
    |> DateTime.shift_zone!("America/Los_Angeles")
    |> Calendar.strftime("%Y %b %d | %H:%M:%S")
  end
end
