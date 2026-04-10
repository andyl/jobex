defmodule JobexWeb.Live.Schedule.Body do
  use JobexWeb, :live_view

  alias JobexCore.CsvManager

  @impl true
  def mount(_params, _session, socket) do
    selected = CsvManager.selected_file()

    {:ok,
     assign(socket, %{
       csv_rows: load_csv_rows(selected),
       quantum_jobs: JobexCore.Scheduler.jobs(),
       selected: selected,
       editing: nil,
       creating: false,
       edit_error: nil,
       create_error: nil,
       sort_by: nil,
       sort_dir: :asc
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
        <%= if display_rows(@csv_rows, @quantum_jobs, @selected) == [] do %>
          <%= for {f, i} <- Enum.with_index(CsvManager.list_files()) do %>
            <%= if i > 0 do %> | <% end %>
            <a href="#" phx-click="load_schedule" phx-value-file={f.name}>Load <%= f.name %></a>
          <% end %>
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

    <%= if display_rows(@csv_rows, @quantum_jobs, @selected) != [] do %>
      <table class="table table-sm">
        <thead>
          <tr>
            <th class="cursor-pointer select-none" phx-click="sort" phx-value-field="schedule">
              Job Schedule <%= sort_indicator(@sort_by, :schedule, @sort_dir) %>
            </th>
            <th class="cursor-pointer select-none" phx-click="sort" phx-value-field="queue">
              Queue <%= sort_indicator(@sort_by, :queue, @sort_dir) %>
            </th>
            <th class="cursor-pointer select-none" phx-click="sort" phx-value-field="type">
              Type <%= sort_indicator(@sort_by, :type, @sort_dir) %>
            </th>
            <th class="cursor-pointer select-none" phx-click="sort" phx-value-field="command">
              Command <%= sort_indicator(@sort_by, :command, @sort_dir) %>
            </th>
            <%= if @selected do %>
              <th>Actions</th>
            <% end %>
          </tr>
        </thead>
        <tbody>
          <%= if @selected do %>
            <%= for {row, idx} <- sorted_csv_rows(@csv_rows, @sort_by, @sort_dir) do %>
              <%= if @editing == idx do %>
                <tr>
                  <td colspan="5">
                    <form phx-submit="save_edit" phx-change="validate_cron_edit" id={"edit-form-#{idx}"}>
                      <input type="hidden" name="index" value={idx} />
                      <div class="flex gap-2 items-center flex-wrap">
                        <input
                          type="text"
                          name="schedule"
                          value={Enum.at(row, 0)}
                          class="input input-xs input-bordered w-28"
                        />
                        <select name="queue" class="select select-xs select-bordered">
                          <option value="serial" selected={Enum.at(row, 1) == "serial"}>serial</option>
                          <option value="parallel" selected={Enum.at(row, 1) == "parallel"}>parallel</option>
                        </select>
                        <input
                          type="text"
                          name="type"
                          value={Enum.at(row, 2)}
                          class="input input-xs input-bordered w-24"
                        />
                        <input
                          type="text"
                          name="command"
                          value={Enum.at(row, 3)}
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
                  <td><code><%= Enum.at(row, 0) %></code></td>
                  <td>{Enum.at(row, 1)}</td>
                  <td>{Enum.at(row, 2)}</td>
                  <td>{Enum.at(row, 3)}</td>
                  <td class="flex gap-1">
                    <button phx-click="edit_job" phx-value-index={idx} class="btn btn-xs btn-ghost">Edit</button>
                    <button phx-click="delete_job" phx-value-index={idx} class="btn btn-xs btn-error btn-outline">Delete</button>
                  </td>
                </tr>
              <% end %>
            <% end %>
          <% else %>
            <%= for {_, job} <- sorted_quantum_jobs(@quantum_jobs, @sort_by, @sort_dir) do %>
              <tr>
                <td><code><%= Crontab.CronExpression.Composer.compose(job.schedule) %></code></td>
                <td>{elem(job.task, 1)}</td>
                <td>{elem(job.task, 2) |> List.first()}</td>
                <td>{elem(job.task, 2) |> List.last()}</td>
              </tr>
            <% end %>
          <% end %>
        </tbody>
      </table>
    <% end %>
    """
  end

  @field_index %{schedule: 0, queue: 1, type: 2, command: 3}

  defp sort_indicator(sort_by, field, dir) when sort_by == field do
    if dir == :asc, do: "▲", else: "▼"
  end

  defp sort_indicator(_, _, _), do: ""

  defp sorted_csv_rows(rows, nil, _dir), do: Enum.with_index(rows)

  defp sorted_csv_rows(rows, field, dir) do
    col = @field_index[field]

    rows
    |> Enum.with_index()
    |> Enum.sort_by(fn {row, _idx} -> Enum.at(row, col) |> String.downcase() end, dir)
  end

  defp sorted_quantum_jobs(jobs, nil, _dir), do: jobs

  defp sorted_quantum_jobs(jobs, field, dir) do
    Enum.sort_by(jobs, fn {_, job} ->
      case field do
        :schedule -> Crontab.CronExpression.Composer.compose(job.schedule)
        :queue -> Atom.to_string(elem(job.task, 1))
        :type -> elem(job.task, 2) |> List.first() |> to_string()
        :command -> elem(job.task, 2) |> List.last() |> to_string()
      end
      |> String.downcase()
    end, dir)
  end

  defp display_rows(csv_rows, quantum_jobs, selected) do
    if selected, do: csv_rows, else: quantum_jobs
  end

  defp load_csv_rows(nil), do: []

  defp load_csv_rows(filename) do
    case CsvManager.read_file(filename) do
      {:ok, rows} -> rows
      _ -> []
    end
  end

  @impl true
  def handle_event("jobstop", _, socket) do
    JobexCore.Scheduler.delete_all_jobs()
    {:noreply, assign(socket, quantum_jobs: [], csv_rows: load_csv_rows(socket.assigns.selected))}
  end

  @impl true
  def handle_event("load_schedule", %{"file" => filename}, socket) do
    JobexCore.Scheduler.load_file(filename)
    CsvManager.select_file(filename)

    {:noreply,
     assign(socket,
       selected: filename,
       quantum_jobs: JobexCore.Scheduler.jobs(),
       csv_rows: load_csv_rows(filename)
     )}
  end

  @valid_sort_fields ~w(schedule queue type command)a

  @impl true
  def handle_event("sort", %{"field" => field_str}, socket) do
    field = String.to_existing_atom(field_str)

    if field in @valid_sort_fields do
      {sort_by, sort_dir} =
        if socket.assigns.sort_by == field do
          if socket.assigns.sort_dir == :asc, do: {field, :desc}, else: {nil, :asc}
        else
          {field, :asc}
        end

      {:noreply, assign(socket, sort_by: sort_by, sort_dir: sort_dir)}
    else
      {:noreply, socket}
    end
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
           csv_rows: load_csv_rows(socket.assigns.selected),
           quantum_jobs: JobexCore.Scheduler.jobs(),
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
           csv_rows: load_csv_rows(socket.assigns.selected),
           quantum_jobs: JobexCore.Scheduler.jobs(),
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
       csv_rows: load_csv_rows(socket.assigns.selected),
       quantum_jobs: JobexCore.Scheduler.jobs(),
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
