defmodule JobexCoreTest do 
  use ExUnit.Case, async: true

  describe "#hello" do
    test "works as expected" do
      assert JobexCore.greeting() == "HELLO"
    end
  end
end
