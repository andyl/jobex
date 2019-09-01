defmodule CrowWeb.Live.Admin.Base do
  use Phoenix.LiveView

  alias CrowData.Repo
  alias CrowData.Ctx.{ObanJob, Result}

  def mount(session, socket) do
    {:ok, assign(socket, %{numjobs: numjobs()})}
  end

  def render(assigns) do
    ~L"""
      <%= if @numjobs > 0 do %>
      <a href='#' phx-click="dbclear">Clear Jobs (<%= @numjobs %>)</a>
      <% end %>
    """
  end

  # ----- event handlers -----

  def handle_event("dbclear", _, socket) do
    Result |> Repo.delete_all()
    ObanJob |> Repo.delete_all()
    {:noreply, assign(socket, %{numjobs: 0})}
  end


  # ----- helpers -----

  defp numjobs do
    CrowData.Query.all_count()
  end

end
