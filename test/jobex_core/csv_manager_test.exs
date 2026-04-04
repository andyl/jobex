defmodule JobexCore.CsvManagerTest do
  use ExUnit.Case, async: true

  alias JobexCore.CsvManager
  alias JobexCore.CsvManager.YamlStore

  setup do
    tmp_dir = Path.join(System.tmp_dir!(), "jobex_test_#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp_dir)
    System.put_env("JOBEX_CSV_DIR", tmp_dir)

    on_exit(fn ->
      File.rm_rf!(tmp_dir)
      System.delete_env("JOBEX_CSV_DIR")
    end)

    %{tmp_dir: tmp_dir}
  end

  describe "csv_dir/0" do
    test "returns JOBEX_CSV_DIR when set", %{tmp_dir: tmp_dir} do
      assert CsvManager.csv_dir() == tmp_dir
    end

    test "falls back to priv/csv when env not set" do
      System.delete_env("JOBEX_CSV_DIR")
      assert CsvManager.csv_dir() |> String.ends_with?("csv")
    end
  end

  describe "valid_filename?/1" do
    test "accepts lowercase alphanumeric with underscores" do
      assert CsvManager.valid_filename?("my_file")
      assert CsvManager.valid_filename?("test123")
      assert CsvManager.valid_filename?("a")
    end

    test "accepts names with .csv extension" do
      assert CsvManager.valid_filename?("my_file.csv")
    end

    test "rejects invalid names" do
      refute CsvManager.valid_filename?("My-File")
      refute CsvManager.valid_filename?("has space")
      refute CsvManager.valid_filename?("UPPER")
      refute CsvManager.valid_filename?("")
      refute CsvManager.valid_filename?("file.txt")
    end
  end

  describe "create_file/1" do
    test "creates a CSV file with header", %{tmp_dir: tmp_dir} do
      assert :ok = CsvManager.create_file("test_jobs")
      path = Path.join(tmp_dir, "test_jobs.csv")
      assert File.exists?(path)
      assert File.read!(path) == "SCHEDULE,QUEUE,TYPE,COMMAND\n"
    end

    test "adds .csv extension if missing" do
      assert :ok = CsvManager.create_file("no_ext")
      assert CsvManager.list_files() |> Enum.any?(&(&1.name == "no_ext.csv"))
    end

    test "rejects invalid filenames" do
      assert {:error, :invalid_filename} = CsvManager.create_file("Bad-Name")
    end

    test "rejects duplicate filenames", %{tmp_dir: tmp_dir} do
      File.write!(Path.join(tmp_dir, "existing.csv"), "SCHEDULE,QUEUE,TYPE,COMMAND\n")
      assert {:error, :already_exists} = CsvManager.create_file("existing")
    end
  end

  describe "list_files/0" do
    test "returns empty list for empty directory" do
      assert CsvManager.list_files() == []
    end

    test "lists CSV files with metadata", %{tmp_dir: tmp_dir} do
      File.write!(Path.join(tmp_dir, "a.csv"), "SCHEDULE,QUEUE,TYPE,COMMAND\n* * * * *,serial,test,date\n")
      File.write!(Path.join(tmp_dir, "b.csv"), "SCHEDULE,QUEUE,TYPE,COMMAND\n")
      File.write!(Path.join(tmp_dir, "not_csv.txt"), "hello")

      files = CsvManager.list_files()
      assert length(files) == 2
      assert Enum.map(files, & &1.name) == ["a.csv", "b.csv"]

      a = Enum.find(files, &(&1.name == "a.csv"))
      assert a.line_count == 1

      b = Enum.find(files, &(&1.name == "b.csv"))
      assert b.line_count == 0
    end
  end

  describe "read_file/1" do
    test "reads and parses CSV rows", %{tmp_dir: tmp_dir} do
      content = "SCHEDULE,QUEUE,TYPE,COMMAND\n* * * * *,serial,test,date\n*/5 * * * *,parallel,check,uptime\n"
      File.write!(Path.join(tmp_dir, "jobs.csv"), content)

      assert {:ok, rows} = CsvManager.read_file("jobs.csv")
      assert length(rows) == 2
      assert List.first(rows) == ["* * * * *", "serial", "test", "date"]
    end

    test "returns error for missing file" do
      assert {:error, :enoent} = CsvManager.read_file("nope.csv")
    end
  end

  describe "rename_file/2" do
    test "renames a file", %{tmp_dir: tmp_dir} do
      File.write!(Path.join(tmp_dir, "old.csv"), "SCHEDULE,QUEUE,TYPE,COMMAND\n")
      assert :ok = CsvManager.rename_file("old.csv", "new_name")
      refute File.exists?(Path.join(tmp_dir, "old.csv"))
      assert File.exists?(Path.join(tmp_dir, "new_name.csv"))
    end

    test "updates .jobex.yml if renamed file was selected", %{tmp_dir: tmp_dir} do
      File.write!(Path.join(tmp_dir, "sel.csv"), "SCHEDULE,QUEUE,TYPE,COMMAND\n")
      YamlStore.write(tmp_dir, "sel.csv")

      assert :ok = CsvManager.rename_file("sel.csv", "renamed")
      assert {:ok, "renamed.csv"} = YamlStore.read(tmp_dir)
    end

    test "rejects invalid new names" do
      assert {:error, :invalid_filename} = CsvManager.rename_file("old.csv", "BAD")
    end

    test "rejects rename to existing file", %{tmp_dir: tmp_dir} do
      File.write!(Path.join(tmp_dir, "a.csv"), "h\n")
      File.write!(Path.join(tmp_dir, "b.csv"), "h\n")
      assert {:error, :already_exists} = CsvManager.rename_file("a.csv", "b")
    end
  end

  describe "delete_file/1" do
    test "deletes a file", %{tmp_dir: tmp_dir} do
      File.write!(Path.join(tmp_dir, "del.csv"), "SCHEDULE,QUEUE,TYPE,COMMAND\n")
      assert :ok = CsvManager.delete_file("del.csv")
      refute File.exists?(Path.join(tmp_dir, "del.csv"))
    end

    test "clears selection if deleted file was selected", %{tmp_dir: tmp_dir} do
      File.write!(Path.join(tmp_dir, "sel.csv"), "SCHEDULE,QUEUE,TYPE,COMMAND\n")
      YamlStore.write(tmp_dir, "sel.csv")

      CsvManager.delete_file("sel.csv")
      assert {:ok, nil} = YamlStore.read(tmp_dir)
    end
  end

  describe "selected_file/0 and select_file/1" do
    test "returns nil when no file is selected" do
      assert CsvManager.selected_file() == nil
    end

    test "selects and retrieves a file", %{tmp_dir: tmp_dir} do
      File.write!(Path.join(tmp_dir, "pick.csv"), "SCHEDULE,QUEUE,TYPE,COMMAND\n")
      assert :ok = CsvManager.select_file("pick.csv")
      assert CsvManager.selected_file() == "pick.csv"
    end

    test "returns nil if selected file no longer exists", %{tmp_dir: tmp_dir} do
      YamlStore.write(tmp_dir, "gone.csv")
      assert CsvManager.selected_file() == nil
    end

    test "returns error when selecting non-existent file" do
      assert {:error, :enoent} = CsvManager.select_file("nope.csv")
    end
  end

  describe "writable?/0" do
    test "returns true for writable directory" do
      assert CsvManager.writable?() == true
    end
  end

  describe "job row CRUD" do
    setup %{tmp_dir: tmp_dir} do
      content = "SCHEDULE,QUEUE,TYPE,COMMAND\n* * * * *,serial,test,date\n*/5 * * * *,parallel,check,uptime\n"
      File.write!(Path.join(tmp_dir, "jobs.csv"), content)
      :ok
    end

    test "add_job/2 appends a row" do
      assert :ok = CsvManager.add_job("jobs.csv", ["*/2 * * * *", "serial", "new", "hostname"])
      assert {:ok, rows} = CsvManager.read_file("jobs.csv")
      assert length(rows) == 3
      assert List.last(rows) == ["*/2 * * * *", "serial", "new", "hostname"]
    end

    test "update_job/3 updates a row by index" do
      assert :ok = CsvManager.update_job("jobs.csv", 0, ["*/3 * * * *", "parallel", "updated", "whoami"])
      assert {:ok, rows} = CsvManager.read_file("jobs.csv")
      assert List.first(rows) == ["*/3 * * * *", "parallel", "updated", "whoami"]
    end

    test "update_job/3 returns error for out of range" do
      assert {:error, :out_of_range} = CsvManager.update_job("jobs.csv", 99, ["a", "b", "c", "d"])
    end

    test "delete_job/2 removes a row by index" do
      assert :ok = CsvManager.delete_job("jobs.csv", 0)
      assert {:ok, rows} = CsvManager.read_file("jobs.csv")
      assert length(rows) == 1
      assert List.first(rows) == ["*/5 * * * *", "parallel", "check", "uptime"]
    end

    test "delete_job/2 returns error for out of range" do
      assert {:error, :out_of_range} = CsvManager.delete_job("jobs.csv", 99)
    end
  end
end
