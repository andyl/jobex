defmodule JobaWeb.Jobs.HomeLive do
  use JobaWeb, :live_view

  alias JobaWeb.Jobs.Components.{HomeBody, HomeSidebar}

  def render(assigns) do
    ~H"""
    
    <div class="flex">
      <div class="bg-blue-200 w-28 p-4">
        <.live_component module={HomeSidebar} id="side"/>
      </div>
      <div class="bg-green-200 flex-auto p-4">
        <.live_component module={HomeBody} id="home"/>
      </div>
    </div>
    """
  end
end
