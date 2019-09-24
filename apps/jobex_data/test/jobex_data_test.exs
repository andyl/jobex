defmodule JobexDataTest do 
  use ExUnit.Case, async: true

  describe "#hello" do
    test "works as expected" do
      assert JobexData.greeting() == "HELLO"
    end
  end
end
