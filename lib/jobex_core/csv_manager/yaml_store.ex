defmodule JobexCore.CsvManager.YamlStore do
  @moduledoc """
  Reads and writes the `.jobex.yml` file that tracks the selected CSV file.
  Hand-parses a single `selected: <filename>` line. Isolated to simplify
  future migration to a YAML library.
  """

  @filename ".jobex.yml"

  def path(dir), do: Path.join(dir, @filename)

  def read(dir) do
    filepath = path(dir)

    case File.read(filepath) do
      {:ok, content} ->
        {:ok, parse(content)}

      {:error, :enoent} ->
        {:ok, nil}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def write(dir, nil) do
    filepath = path(dir)
    File.rm(filepath)
    :ok
  end

  def write(dir, filename) when is_binary(filename) do
    filepath = path(dir)
    File.write(filepath, "selected: #{filename}\n")
  end

  defp parse(content) do
    content
    |> String.trim()
    |> case do
      "selected: " <> value ->
        value = String.trim(value)
        if value == "", do: nil, else: value

      _ ->
        nil
    end
  end
end
