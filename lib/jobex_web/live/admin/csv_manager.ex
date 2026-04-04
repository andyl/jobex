defmodule JobexWeb.Live.Admin.CsvManager do
  use JobexWeb, :live_view

  alias JobexCore.CsvManager

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       files: CsvManager.list_files(),
       selected: CsvManager.selected_file(),
       writable: CsvManager.writable?(),
       confirm_delete: nil,
       preview_file: nil,
       preview_data: [],
       renaming: nil,
       rename_error: nil,
       create_error: nil,
       job_count: length(JobexCore.Scheduler.jobs())
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex justify-between items-center mb-3">
        <h4 class="font-semibold">CSV Files</h4>
        <span class="text-sm">
          <%= if @selected do %>
            Selected: <strong><%= @selected %></strong>
            (<%= @job_count %> jobs loaded)
          <% else %>
            No file selected
          <% end %>
        </span>
      </div>

      <table class="table table-sm table-zebra w-full mb-4">
        <thead>
          <tr>
            <th>File</th>
            <th>Jobs</th>
            <th>Updated</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <%= for file <- @files do %>
            <tr class={if file.name == @selected, do: "bg-primary/10", else: ""}>
              <td>
                <%= if @renaming == file.name do %>
                  <form phx-submit="save_rename" class="flex gap-1 items-center">
                    <input type="hidden" name="old_name" value={file.name} />
                    <input
                      type="text"
                      name="new_name"
                      value={file.name |> String.replace_trailing(".csv", "")}
                      class="input input-xs input-bordered w-40"
                      autofocus
                    />
                    <button type="submit" class="btn btn-xs btn-success">Save</button>
                    <button type="button" phx-click="cancel_rename" class="btn btn-xs">Cancel</button>
                    <%= if @rename_error do %>
                      <span class="text-error text-xs"><%= @rename_error %></span>
                    <% end %>
                  </form>
                <% else %>
                  <%= file.name %>
                  <%= if file.name == @selected do %>
                    <span class="badge badge-primary badge-xs ml-1">active</span>
                  <% end %>
                <% end %>
              </td>
              <td><%= file.line_count %></td>
              <td class="text-xs"><%= format_datetime(file.updated_at) %></td>
              <td class="flex gap-1 flex-wrap">
                <%= if file.name != @selected do %>
                  <button phx-click="select" phx-value-file={file.name} class="btn btn-xs btn-primary">
                    Select
                  </button>
                <% else %>
                  <button phx-click="reload" class="btn btn-xs btn-info">
                    Reload
                  </button>
                <% end %>
                <button
                  phx-click="preview"
                  phx-value-file={file.name}
                  class="btn btn-xs btn-ghost hidden sm:inline-flex"
                >
                  Preview
                </button>
                <%= if @writable do %>
                  <button phx-click="rename" phx-value-file={file.name} class="btn btn-xs btn-ghost">
                    Rename
                  </button>
                  <button phx-click="delete" phx-value-file={file.name} class="btn btn-xs btn-error btn-outline">
                    Delete
                  </button>
                <% end %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>

      <%= if @writable do %>
        <form phx-submit="create" class="flex gap-2 items-center">
          <input
            type="text"
            name="filename"
            placeholder="new_file_name"
            class="input input-sm input-bordered w-48"
          />
          <button type="submit" class="btn btn-sm btn-success">Create File</button>
          <%= if @create_error do %>
            <span class="text-error text-sm"><%= @create_error %></span>
          <% end %>
        </form>
      <% end %>

      <%= if @confirm_delete do %>
        <div class="modal modal-open">
          <div class="modal-box">
            <h3 class="font-bold text-lg">Delete File</h3>
            <p class="py-4">
              Are you sure you want to delete <strong><%= @confirm_delete %></strong>?
              This cannot be undone.
            </p>
            <div class="modal-action">
              <button phx-click="cancel_delete" class="btn">Cancel</button>
              <button phx-click="confirm_delete" class="btn btn-error">Delete</button>
            </div>
          </div>
          <div class="modal-backdrop" phx-click="cancel_delete"></div>
        </div>
      <% end %>

      <%= if @preview_file do %>
        <div class="modal modal-open">
          <div class="modal-box max-w-3xl">
            <h3 class="font-bold text-lg mb-3">Preview: <%= @preview_file %></h3>
            <%= if @preview_data == [] do %>
              <p class="text-sm italic">No data rows</p>
            <% else %>
              <div class="overflow-x-auto">
                <table class="table table-xs table-zebra w-full">
                  <thead>
                    <tr>
                      <th>Schedule</th>
                      <th>Queue</th>
                      <th>Type</th>
                      <th>Command</th>
                    </tr>
                  </thead>
                  <tbody>
                    <%= for row <- @preview_data do %>
                      <tr>
                        <td><code><%= Enum.at(row, 0) %></code></td>
                        <td><%= Enum.at(row, 1) %></td>
                        <td><%= Enum.at(row, 2) %></td>
                        <td><code><%= Enum.at(row, 3) %></code></td>
                      </tr>
                    <% end %>
                  </tbody>
                </table>
              </div>
            <% end %>
            <div class="modal-action">
              <button phx-click="close_preview" class="btn">Close</button>
            </div>
          </div>
          <div class="modal-backdrop" phx-click="close_preview"></div>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("select", %{"file" => filename}, socket) do
    CsvManager.select_file(filename)
    JobexCore.Scheduler.load_file(filename)

    {:noreply,
     assign(socket,
       selected: filename,
       files: CsvManager.list_files(),
       job_count: length(JobexCore.Scheduler.jobs())
     )}
  end

  @impl true
  def handle_event("reload", _, socket) do
    case socket.assigns.selected do
      nil ->
        {:noreply, socket}

      filename ->
        JobexCore.Scheduler.load_file(filename)

        {:noreply,
         assign(socket,
           job_count: length(JobexCore.Scheduler.jobs())
         )}
    end
  end

  @impl true
  def handle_event("delete", %{"file" => filename}, socket) do
    {:noreply, assign(socket, confirm_delete: filename)}
  end

  @impl true
  def handle_event("confirm_delete", _, socket) do
    filename = socket.assigns.confirm_delete
    CsvManager.delete_file(filename)

    new_selected =
      if socket.assigns.selected == filename do
        JobexCore.Scheduler.delete_all_jobs()
        nil
      else
        socket.assigns.selected
      end

    {:noreply,
     assign(socket,
       confirm_delete: nil,
       files: CsvManager.list_files(),
       selected: new_selected,
       job_count: length(JobexCore.Scheduler.jobs())
     )}
  end

  @impl true
  def handle_event("cancel_delete", _, socket) do
    {:noreply, assign(socket, confirm_delete: nil)}
  end

  @impl true
  def handle_event("rename", %{"file" => filename}, socket) do
    {:noreply, assign(socket, renaming: filename, rename_error: nil)}
  end

  @impl true
  def handle_event("save_rename", %{"old_name" => old_name, "new_name" => new_name}, socket) do
    case CsvManager.rename_file(old_name, new_name) do
      :ok ->
        new_full = if String.ends_with?(new_name, ".csv"), do: new_name, else: new_name <> ".csv"

        new_selected =
          if socket.assigns.selected == old_name, do: new_full, else: socket.assigns.selected

        {:noreply,
         assign(socket,
           renaming: nil,
           rename_error: nil,
           files: CsvManager.list_files(),
           selected: new_selected
         )}

      {:error, :invalid_filename} ->
        {:noreply, assign(socket, rename_error: "Only lowercase letters, numbers, and underscores allowed")}

      {:error, :already_exists} ->
        {:noreply, assign(socket, rename_error: "A file with that name already exists")}

      {:error, _} ->
        {:noreply, assign(socket, rename_error: "Rename failed")}
    end
  end

  @impl true
  def handle_event("cancel_rename", _, socket) do
    {:noreply, assign(socket, renaming: nil, rename_error: nil)}
  end

  @impl true
  def handle_event("preview", %{"file" => filename}, socket) do
    case CsvManager.read_file(filename) do
      {:ok, rows} ->
        {:noreply, assign(socket, preview_file: filename, preview_data: rows)}

      {:error, _} ->
        {:noreply, assign(socket, preview_file: filename, preview_data: [])}
    end
  end

  @impl true
  def handle_event("close_preview", _, socket) do
    {:noreply, assign(socket, preview_file: nil, preview_data: [])}
  end

  @impl true
  def handle_event("create", %{"filename" => filename}, socket) do
    case CsvManager.create_file(filename) do
      :ok ->
        {:noreply,
         assign(socket,
           files: CsvManager.list_files(),
           create_error: nil
         )}

      {:error, :invalid_filename} ->
        {:noreply, assign(socket, create_error: "Only lowercase letters, numbers, and underscores allowed")}

      {:error, :already_exists} ->
        {:noreply, assign(socket, create_error: "A file with that name already exists")}

      {:error, _} ->
        {:noreply, assign(socket, create_error: "Create failed")}
    end
  end

  defp format_datetime({{year, month, day}, {hour, min, _sec}}) do
    :io_lib.format("~4..0B-~2..0B-~2..0B ~2..0B:~2..0B", [year, month, day, hour, min])
    |> to_string()
  end
end
