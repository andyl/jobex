defmodule CrowDataTest do 
  use ExUnit.Case, async: true

  describe "#hello" do
    test "works as expected" do
      assert CrowData.greeting() == "HELLO"
    end
  end
end
