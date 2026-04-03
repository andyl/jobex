defmodule JobexWeb.Live.Component.TitleComp do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <h1>Title</h1>
    """
  end
end
