defmodule ExampleSystem.MathTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import StreamData
  alias ExampleSystem.Math

  property "correct sum is returned for valid input" do
    check all n <- valid_input() do
      assert {:ok, pid} = Math.sum(n)
      assert_receive({:sum, ^pid, sum})
      assert sum == Enum.sum(1..n)
    end
  end

  property "the caller receives a down message when the sum process finishes" do
    check all n <- valid_input() do
      ExUnit.CaptureLog.capture_log(fn ->
        assert {:ok, pid} = Math.sum(n)
        assert_receive {:DOWN, _mref, :process, ^pid, _reason}
      end)
    end
  end

  test "large input" do
    n = 999_999_999
    assert {:ok, pid} = Math.sum(n)
    assert_receive({:sum, ^pid, sum})
    assert sum == Enum.sum(1..n)
  end

  defp valid_input(), do: positive_integer()
end
