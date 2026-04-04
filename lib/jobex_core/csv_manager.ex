defmodule JobexCore.CsvManager do
  @moduledoc """
  Context module for all CSV file operations: listing, reading, creating,
  renaming, deleting, and tracking the selected file.
  """

  alias NimbleCSV.RFC4180, as: CSV
  alias JobexCore.CsvManager.YamlStore

  @csv_header "SCHEDULE,QUEUE,TYPE,COMMAND"

  def csv_dir do
    System.get_env("JOBEX_CSV_DIR") ||
      Path.join(JobexCore.Scheduler.priv_dir(), "csv")
  end

  def list_files do
    dir = csv_dir()

    case File.ls(dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.ends_with?(&1, ".csv"))
        |> Enum.sort()
        |> Enum.map(fn name ->
          path = Path.join(dir, name)
          stat = File.stat!(path)

          line_count =
            path
            |> File.read!()
            |> String.split("\n", trim: true)
            |> length()
            |> Kernel.-(1)
            |> max(0)

          %{
            name: name,
            line_count: line_count,
            updated_at: stat.mtime
          }
        end)

      {:error, _} ->
        []
    end
  end

  def read_file(filename) do
    path = Path.join(csv_dir(), filename)

    case File.read(path) do
      {:ok, content} ->
        rows =
          content
          |> String.replace(~r/ +/, " ")
          |> String.replace(", ", ",")
          |> CSV.parse_string(skip_headers: true)

        {:ok, rows}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def create_file(filename) do
    with :ok <- validate_filename(filename),
         path = Path.join(csv_dir(), ensure_csv_ext(filename)),
         :ok <- check_not_exists(path) do
      File.write(path, @csv_header <> "\n")
    end
  end

  def rename_file(old_name, new_name) do
    with :ok <- validate_filename(new_name) do
      old_path = Path.join(csv_dir(), old_name)
      new_full = ensure_csv_ext(new_name)
      new_path = Path.join(csv_dir(), new_full)

      with :ok <- check_not_exists(new_path) do
        case File.rename(old_path, new_path) do
          :ok ->
            case YamlStore.read(csv_dir()) do
              {:ok, ^old_name} -> YamlStore.write(csv_dir(), new_full)
              _ -> :ok
            end

          error ->
            error
        end
      end
    end
  end

  def delete_file(filename) do
    path = Path.join(csv_dir(), filename)

    case File.rm(path) do
      :ok ->
        case YamlStore.read(csv_dir()) do
          {:ok, ^filename} -> YamlStore.write(csv_dir(), nil)
          _ -> :ok
        end

      error ->
        error
    end
  end

  def valid_filename?(name) do
    base = name |> String.replace_trailing(".csv", "")
    Regex.match?(~r/^[a-z0-9_]+$/, base) and base != ""
  end

  def selected_file do
    case YamlStore.read(csv_dir()) do
      {:ok, nil} ->
        nil

      {:ok, filename} ->
        path = Path.join(csv_dir(), filename)
        if File.exists?(path), do: filename, else: nil

      {:error, _} ->
        nil
    end
  end

  def select_file(nil), do: YamlStore.write(csv_dir(), nil)

  def select_file(filename) do
    path = Path.join(csv_dir(), filename)

    if File.exists?(path) do
      YamlStore.write(csv_dir(), filename)
    else
      {:error, :enoent}
    end
  end

  def writable? do
    dir = csv_dir()
    test_path = Path.join(dir, ".write_test_#{System.unique_integer([:positive])}")

    case File.write(test_path, "") do
      :ok ->
        File.rm(test_path)
        true

      {:error, _} ->
        false
    end
  end

  # Job-row CRUD (Phase 2)

  def add_job(filename, row) when is_list(row) do
    path = Path.join(csv_dir(), filename)

    case File.read(path) do
      {:ok, content} ->
        trimmed = String.trim_trailing(content)
        new_line = Enum.join(row, ",")
        File.write(path, trimmed <> "\n" <> new_line <> "\n")

      error ->
        error
    end
  end

  def update_job(filename, index, row) when is_list(row) do
    path = Path.join(csv_dir(), filename)

    with {:ok, content} <- File.read(path) do
      lines = String.split(content, "\n", trim: true)
      # index 0 = first data row, line 0 = header
      data_index = index + 1

      if data_index >= length(lines) do
        {:error, :out_of_range}
      else
        new_line = Enum.join(row, ",")
        updated = List.replace_at(lines, data_index, new_line)
        File.write(path, Enum.join(updated, "\n") <> "\n")
      end
    end
  end

  def delete_job(filename, index) do
    path = Path.join(csv_dir(), filename)

    with {:ok, content} <- File.read(path) do
      lines = String.split(content, "\n", trim: true)
      data_index = index + 1

      if data_index >= length(lines) do
        {:error, :out_of_range}
      else
        updated = List.delete_at(lines, data_index)
        File.write(path, Enum.join(updated, "\n") <> "\n")
      end
    end
  end

  # Private helpers

  defp validate_filename(name) do
    if valid_filename?(name), do: :ok, else: {:error, :invalid_filename}
  end

  defp ensure_csv_ext(name) do
    if String.ends_with?(name, ".csv"), do: name, else: name <> ".csv"
  end

  defp check_not_exists(path) do
    if File.exists?(path), do: {:error, :already_exists}, else: :ok
  end
end
