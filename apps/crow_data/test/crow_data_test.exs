defmodule CrowDataTest do 
  use ExUnit.Case, async: true

  describe "#hello" do
    test "works as expected" do
      assert CrowData.hello = "world"
    end
  end
end
