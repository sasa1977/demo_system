defmodule ExampleSystem.MathTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import StreamData

  property "returns the correct sum for a valid input" do
    check all x <- positive_integer(), x != 13 do
      assert ExampleSystem.Math.sync_sum(x) == {:ok, Enum.sum(1..x)}
    end
  end
end
