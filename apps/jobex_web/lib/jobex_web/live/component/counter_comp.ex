defmodule JobexWeb.Live.Component.CounterComp do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div>
      <h4>CounterComponent: <%= @count %></h4>
      <button phx-click="com_dec">-</button>
      <button phx-click="com_inc">+</button>
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
