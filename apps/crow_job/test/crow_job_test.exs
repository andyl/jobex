defmodule CrowJobTest do
  use ExUnit.Case
  doctest CrowJob

  test "greets the world" do
    assert CrowJob.hello() == :world
  end
end
