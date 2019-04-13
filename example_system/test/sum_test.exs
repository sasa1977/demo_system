defmodule ExampleSystemWeb.SumTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import Phoenix.LiveViewTest
  import Assertions
  alias ExampleSystemWeb.Math.Sum

  property "flow for valid input" do
    check all number <- valid_input(), expected_sum = Enum.sum(1..number) do
      {:ok, view, _html} = mount_disconnected(ExampleSystemWeb.Endpoint, Sum, session: %{})
      {:ok, view, _html} = mount(view)

      html = render_submit(view, "submit", %{"data" => %{"to" => to_string(number)}})
      assert String.contains?(html, "∑(1..#{number}) = calculating")

      assert_async(timeout: :timer.seconds(1), sleep_time: 10) do
        assert String.contains?(render(view), "∑(1..#{number}) = #{expected_sum}")
      end
    end
  end

  property "reporting errors for invalid input" do
    check all input <- invalid_input() do
      {:ok, view, _html} = mount_disconnected(ExampleSystemWeb.Endpoint, Sum, session: %{})
      {:ok, view, _html} = mount(view)

      html = render_submit(view, "submit", %{"data" => %{"to" => to_string(input)}})
      assert String.contains?(html, "∑(1..#{input}) = invalid input")
    end
  end

  defp valid_input(), do: positive_integer()
  defp invalid_input(), do: one_of([non_positive_integer(), invalid_string()])

  defp invalid_string() do
    one_of([
      constant(""),
      string_which_starts_with_letter(),
      invalid_string_which_starts_with_number(),
      float_string()
    ])
  end

  defp string_which_starts_with_letter() do
    gen all prefix <- string([?A..?Z, ?a..?z], min_length: 1),
            suffix <- string([?A..?Z, ?a..?z], min_length: 1),
            do: prefix <> suffix
  end

  defp invalid_string_which_starts_with_number() do
    gen all number <- valid_input(),
            suffix <- string_which_starts_with_letter(),
            do: to_string(number) <> suffix
  end

  defp float_string() do
    gen all integer_part <- non_negative_integer(),
            decimal_part <- non_negative_integer(),
            do: "#{integer_part}.#{decimal_part}"
  end

  defp non_negative_integer(), do: map(positive_integer(), &(&1 - 1))
  defp non_positive_integer(), do: map(non_negative_integer(), &(-&1))
end
