defmodule JobexWeb.Live.Component.TitleComp do
  use JobexWeb, :live_component

  def render(assigns) do
    ~H"""
    <h1>Title</h1>
    """
  end
end
