defmodule JobexWeb.Live.Component.CounterComp do
  use JobexWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <h4>CounterComponent: {@count}</h4>
      <button phx-click="com_dec" phx-target={@myself}>-</button>
      <button phx-click="com_inc" phx-target={@myself}>+</button>
    </div>
    """
  end

  def handle_event("com_inc", _, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_event("com_dec", _, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end
end
