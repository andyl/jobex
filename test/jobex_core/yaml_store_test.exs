defmodule JobexCore.CsvManager.YamlStoreTest do
  use ExUnit.Case, async: true

  alias JobexCore.CsvManager.YamlStore

  setup do
    tmp_dir = Path.join(System.tmp_dir!(), "jobex_yaml_test_#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp_dir)

    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    %{dir: tmp_dir}
  end

  test "read returns nil when file doesn't exist", %{dir: dir} do
    assert {:ok, nil} = YamlStore.read(dir)
  end

  test "write and read round-trip", %{dir: dir} do
    assert :ok = YamlStore.write(dir, "my_file.csv")
    assert {:ok, "my_file.csv"} = YamlStore.read(dir)
  end

  test "write nil removes the file", %{dir: dir} do
    YamlStore.write(dir, "file.csv")
    YamlStore.write(dir, nil)
    refute File.exists?(YamlStore.path(dir))
    assert {:ok, nil} = YamlStore.read(dir)
  end

  test "handles malformed content gracefully", %{dir: dir} do
    File.write!(YamlStore.path(dir), "garbage content")
    assert {:ok, nil} = YamlStore.read(dir)
  end

  test "handles empty file", %{dir: dir} do
    File.write!(YamlStore.path(dir), "")
    assert {:ok, nil} = YamlStore.read(dir)
  end
end
