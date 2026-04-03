defmodule JobexWeb.Live.Schedule.Body do
  use JobexWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign(socket, %{schedule: session["schedule"]})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex justify-between items-center">
      <h3>SCHEDULE</h3>
      <div class="text-sm">
        <%= if @schedule == [] do %>
          <a href="#" phx-click="devload">Load Dev Schedule</a>
          |
          <a href="#" phx-click="prodload">Load Prod Schedule</a>
        <% else %>
          <a href="#" phx-click="jobstop">Clear Schedule</a>
        <% end %>
      </div>
    </div>
    <%= if @schedule != [] do %>
      <table class="table table-sm">
        <thead>
          <tr>
            <th>Job Schedule</th>
            <th>Queue</th>
            <th>Type</th>
            <th>Command</th>
          </tr>
        </thead>
        <tbody>
          <%= for {_, job} <- @schedule do %>
            <tr>
              <td>{inspect(job.schedule)}</td>
              <td>{elem(job.task, 1)}</td>
              <td>{elem(job.task, 2) |> List.first()}</td>
              <td>{elem(job.task, 2) |> List.last()}</td>
            </tr>
          <% end %>
        </tbody>
      </table>
    <% end %>
    """
  end

  @impl true
  def handle_event("jobstop", _, socket) do
    JobexCore.Scheduler.delete_all_jobs()
    {:noreply, assign(socket, %{schedule: []})}
  end

  @impl true
  def handle_event("devload", _, socket) do
    JobexCore.Scheduler.load_dev_jobs()
    {:noreply, assign(socket, %{schedule: JobexCore.Scheduler.jobs()})}
  end

  @impl true
  def handle_event("prodload", _, socket) do
    JobexCore.Scheduler.load_prod_jobs()
    {:noreply, assign(socket, %{schedule: JobexCore.Scheduler.jobs()})}
  end
end
