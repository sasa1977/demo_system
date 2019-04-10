defmodule ExampleSystem.MathTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import StreamData
  alias ExampleSystem.Math

  property "correct sum is returned for valid input" do
    check all x <- valid_input() do
      assert {:ok, pid} = Math.sum(x)
      assert_receive({:sum, ^pid, sum})
      assert sum == Enum.sum(1..x)
    end
  end

  property "the caller receives a down message when the sum process finishes" do
    check all x <- one_of([valid_input(), constant(13)]) do
      ExUnit.CaptureLog.capture_log(fn ->
        assert {:ok, pid} = Math.sum(x)
        assert_receive {:DOWN, _mref, :process, ^pid, _reason}
      end)
    end
  end

  test "crash in a sum operation is logged" do
    log =
      ExUnit.CaptureLog.capture_log(fn ->
        assert {:ok, pid} = Math.sum(13)
        assert_receive {:DOWN, _mref, :process, ^pid, _reason}
      end)

    assert log =~ ~r/Task.*started from #{inspect(self())}/
  end

  defp valid_input(), do: filter(positive_integer(), &(&1 != 13))
end
