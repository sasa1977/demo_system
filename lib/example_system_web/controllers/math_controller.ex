defmodule ExampleSystemWeb.MathController do
  use ExampleSystemWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", result: nil
  end

  def sum(conn, %{"number" => number_str}) do
    to = String.to_integer(number_str)
    result = calc_sum(1, to, 0)
    render conn, "index.html", result: result, to: to
  end

  defp calc_sum(from, from, sum), do: sum + from
  defp calc_sum(from, to, acc_sum), do:
    calc_sum(from + 1, to, acc_sum + from)
end
