defmodule JobexIo do
  @moduledoc """
  Documentation for `JobexIo`.
  """

  def broadcast(topic, payload) do
    JobexIo.PubSub
    |> Phoenix.PubSub.broadcast(topic, payload)
  end

  def subscribe(topic) do
    JobexIo.PubSub
    |> Phoenix.PubSub.subscribe(topic)
  end
end
