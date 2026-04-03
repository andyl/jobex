defmodule JobexWeb.Live.Admin.Base do
  use JobexWeb, :live_view

  alias JobexCore.Repo
  alias JobexCore.Ctx.{ObanJob, Result}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{numjobs: numjobs()})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @numjobs > 0 do %>
      <a href="#" phx-click="dbclear">Clear Jobs ({@numjobs})</a>
    <% end %>
    """
  end

  @impl true
  def handle_event("dbclear", _, socket) do
    Result |> Repo.delete_all()
    ObanJob |> Repo.delete_all()
    {:noreply, assign(socket, %{numjobs: 0})}
  end

  defp numjobs do
    JobexCore.Query.all_count()
  end
end
