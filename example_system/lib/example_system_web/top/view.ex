defmodule ExampleSystemWeb.Top.View do
  use ExampleSystemWeb, :view

  defp stringify_pid(pid),
    do: pid |> inspect() |> String.replace(~r/^#PID</, "") |> String.replace(~r/>$/, "")
end
