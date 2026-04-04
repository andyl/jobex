defmodule JobexWeb.Live.Schedule.Body do
  use JobexWeb, :live_view

  alias JobexCore.CsvManager

  @impl true
  def mount(_params, _session, socket) do
    selected = CsvManager.selected_file()

    {:ok,
     assign(socket, %{
       schedule: JobexCore.Scheduler.jobs(),
       selected: selected,
       editing: nil,
       creating: false,
       edit_error: nil,
       create_error: nil
     })}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex justify-between items-center">
      <h3>
        SCHEDULE
        <%= if @selected do %>
          <span class="text-sm font-normal ml-2">(<%= @selected %>)</span>
        <% end %>
      </h3>
      <div class="text-sm flex gap-2 items-center">
        <%= if @schedule == [] do %>
          <a href="#" phx-click="devload">Load Dev Schedule</a>
          |
          <a href="#" phx-click="prodload">Load Prod Schedule</a>
        <% else %>
          <a href="#" phx-click="jobstop">Clear Schedule</a>
        <% end %>
        <%= if @selected && !@creating do %>
          | <a href="#" phx-click="new_job">Add Job</a>
        <% end %>
      </div>
    </div>

    <%= if @creating do %>
      <div class="my-3 p-3 border border-base-300 rounded">
        <form phx-submit="create_job" phx-change="validate_cron">
          <div class="flex gap-2 items-end flex-wrap">
            <div>
              <label class="label label-text text-xs">Schedule</label>
              <input type="text" name="schedule" placeholder="* * * * *" class="input input-sm input-bordered w-36" />
            </div>
            <div>
              <label class="label label-text text-xs">Queue</label>
              <select name="queue" class="select select-sm select-bordered">
                <option value="serial">serial</option>
                <option value="parallel">parallel</option>
              </select>
            </div>
            <div>
              <label class="label label-text text-xs">Type</label>
              <input type="text" name="type" placeholder="type" class="input input-sm input-bordered w-28" />
            </div>
            <div>
              <label class="label label-text text-xs">Command</label>
              <input type="text" name="command" placeholder="command" class="input input-sm input-bordered w-48" />
            </div>
            <button type="submit" class="btn btn-sm btn-success">Add</button>
            <button type="button" phx-click="cancel_create" class="btn btn-sm">Cancel</button>
          </div>
          <%= if @create_error do %>
            <p class="text-error text-xs mt-1"><%= @create_error %></p>
          <% end %>
        </form>
      </div>
    <% end %>

    <%= if @schedule != [] do %>
      <table class="table table-sm">
        <thead>
          <tr>
            <th>Job Schedule</th>
            <th>Queue</th>
            <th>Type</th>
            <th>Command</th>
            <%= if @selected do %>
              <th>Actions</th>
            <% end %>
          </tr>
        </thead>
        <tbody>
          <%= for {{_, job}, idx} <- Enum.with_index(@schedule) do %>
            <%= if @editing == idx do %>
              <tr>
                <td colspan={if @selected, do: 5, else: 4}>
                  <form phx-submit="save_edit" phx-change="validate_cron_edit" id={"edit-form-#{idx}"}>
                    <input type="hidden" name="index" value={idx} />
                    <div class="flex gap-2 items-center flex-wrap">
                      <input
                        type="text"
                        name="schedule"
                        value={Crontab.CronExpression.Composer.compose(job.schedule)}
                        class="input input-xs input-bordered w-28"
                      />
                      <select name="queue" class="select select-xs select-bordered">
                        <option value="serial" selected={elem(job.task, 1) == :serial}>serial</option>
                        <option value="parallel" selected={elem(job.task, 1) == :parallel}>parallel</option>
                      </select>
                      <input
                        type="text"
                        name="type"
                        value={elem(job.task, 2) |> List.first()}
                        class="input input-xs input-bordered w-24"
                      />
                      <input
                        type="text"
                        name="command"
                        value={elem(job.task, 2) |> List.last()}
                        class="input input-xs input-bordered w-40"
                      />
                      <button type="submit" class="btn btn-xs btn-success">Save</button>
                      <button type="button" phx-click="cancel_edit" class="btn btn-xs">Cancel</button>
                      <%= if @edit_error do %>
                        <span class="text-error text-xs"><%= @edit_error %></span>
                      <% end %>
                    </div>
                  </form>
                </td>
              </tr>
            <% else %>
              <tr>
                <td><code><%= Crontab.CronExpression.Composer.compose(job.schedule) %></code></td>
                <td>{elem(job.task, 1)}</td>
                <td>{elem(job.task, 2) |> List.first()}</td>
                <td>{elem(job.task, 2) |> List.last()}</td>
                <%= if @selected do %>
                  <td class="flex gap-1">
                    <button phx-click="edit_job" phx-value-index={idx} class="btn btn-xs btn-ghost">Edit</button>
                    <button phx-click="delete_job" phx-value-index={idx} class="btn btn-xs btn-error btn-outline">Delete</button>
                  </td>
                <% end %>
              </tr>
            <% end %>
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

  # Phase 2: Job CRUD

  @impl true
  def handle_event("new_job", _, socket) do
    {:noreply, assign(socket, creating: true, create_error: nil)}
  end

  @impl true
  def handle_event("cancel_create", _, socket) do
    {:noreply, assign(socket, creating: false, create_error: nil)}
  end

  @impl true
  def handle_event("validate_cron", %{"schedule" => cron}, socket) do
    error = validate_cron_expr(cron)
    {:noreply, assign(socket, create_error: error)}
  end

  @impl true
  def handle_event("create_job", params, socket) do
    %{"schedule" => sched, "queue" => queue, "type" => type, "command" => cmd} = params

    case validate_cron_expr(sched) do
      nil ->
        row = [sched, queue, type, cmd]
        CsvManager.add_job(socket.assigns.selected, row)
        JobexCore.Scheduler.load_file(socket.assigns.selected)

        {:noreply,
         assign(socket,
           schedule: JobexCore.Scheduler.jobs(),
           creating: false,
           create_error: nil
         )}

      error ->
        {:noreply, assign(socket, create_error: error)}
    end
  end

  @impl true
  def handle_event("edit_job", %{"index" => index}, socket) do
    {:noreply, assign(socket, editing: String.to_integer(index), edit_error: nil)}
  end

  @impl true
  def handle_event("cancel_edit", _, socket) do
    {:noreply, assign(socket, editing: nil, edit_error: nil)}
  end

  @impl true
  def handle_event("validate_cron_edit", %{"schedule" => cron}, socket) do
    error = validate_cron_expr(cron)
    {:noreply, assign(socket, edit_error: error)}
  end

  @impl true
  def handle_event("save_edit", params, socket) do
    %{"index" => index, "schedule" => sched, "queue" => queue, "type" => type, "command" => cmd} = params
    idx = String.to_integer(index)

    case validate_cron_expr(sched) do
      nil ->
        row = [sched, queue, type, cmd]
        CsvManager.update_job(socket.assigns.selected, idx, row)
        JobexCore.Scheduler.load_file(socket.assigns.selected)

        {:noreply,
         assign(socket,
           schedule: JobexCore.Scheduler.jobs(),
           editing: nil,
           edit_error: nil
         )}

      error ->
        {:noreply, assign(socket, edit_error: error)}
    end
  end

  @impl true
  def handle_event("delete_job", %{"index" => index}, socket) do
    idx = String.to_integer(index)
    CsvManager.delete_job(socket.assigns.selected, idx)
    JobexCore.Scheduler.load_file(socket.assigns.selected)

    {:noreply,
     assign(socket,
       schedule: JobexCore.Scheduler.jobs(),
       editing: nil
     )}
  end

  defp validate_cron_expr(""), do: "Schedule is required"

  defp validate_cron_expr(expr) do
    case Crontab.CronExpression.Parser.parse(expr) do
      {:ok, _} -> nil
      {:error, _} -> "Invalid cron expression"
    end
  rescue
    _ -> "Invalid cron expression"
  end
end
