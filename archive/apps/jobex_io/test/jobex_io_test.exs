defmodule JobexIoTest do
  use ExUnit.Case
  doctest JobexIo

  test "greets the world" do
    assert JobexIo.hello() == :world
  end
end
