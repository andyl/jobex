defmodule CrowWeb.Live.Admin.Body do
  use Phoenix.LiveView

  alias CrowData.Repo
  alias CrowData.Ctx.{ObanJob, Result}

  def mount(session, socket) do
    {:ok, assign(socket, %{numjobs: numjobs(), schedule: session.schedule})}
  end

  def render(assigns) do
    ~L"""
    <div class="row">
    <div class="col-md-3">
    <h3>ADMIN</h3>
    </div>
    <div class="col-md-9 text-right">
    <small>
    <%= if @schedule == [] do %>
      <%= if @numjobs > 0 do %>
    <a href='#' phx-click="dbclear">Clear Jobs (<%= @numjobs %>)</a>
    |
        <% end %>
    <a href='#' phx-click="devload">Load Dev Schedule</a>
    |
    <a href='#' phx-click="prodload">Load Prod Schedule</a>
    <% else %>
    <a href='#' phx-click="jobstop">Clear Job Schedule</a>
    <% end %>
    </small>
    </div>
    </div>
    <%= if @schedule != [] do %>
    <table class="table table-sm">
      <thead>
        <tr>
            <th>Job Type</th>
            <th>Queue</th>
            <th>Schedule</th>
            <th>Command</th>
        </tr>
      </thead>
      <tbody>
      <%= for {_, job} <- @schedule do %>
        <tr>
          <td><%= elem(job.task, 2) |> List.first() %></td>
          <td><%= elem(job.task, 1) %></td>
          <td><%= inspect(job.schedule) %></td>
          <td><%= elem(job.task, 2) |> List.last() %></td>
        </tr>
      <% end %>
      </tbody>
    </table>
    <% end %>
    """
  end

  # ----- event handlers -----

  def handle_event("jobstop", _, socket) do
    CrowData.Scheduler.delete_all_jobs()
    {:noreply, assign(socket, %{numjobs: numjobs(), schedule: []})}
  end

  def handle_event("dbclear", _, socket) do
    Result |> Repo.delete_all()
    ObanJob |> Repo.delete_all()
    {:noreply, assign(socket, %{numjobs: 0})}
  end

  def handle_event("devload", _, socket) do
    CrowData.Scheduler.load_dev_jobs()
    {:noreply, assign(socket, %{numjobs: numjobs(), schedule: CrowData.Scheduler.jobs()})}
  end

  def handle_event("prodload", _, socket) do
    CrowData.Scheduler.load_prod_jobs()
    {:noreply, assign(socket, %{numjobs: numjobs(), schedule: CrowData.Scheduler.jobs()})}
  end

  # ----- helpers -----

  defp numjobs do
    CrowData.Query.all_count()
  end
end
