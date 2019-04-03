defmodule ExampleSystemWeb.Top.View do
  use ExampleSystemWeb.Base.View, root: "lib/example_system_web"

  defp stringify_pid(pid), do: pid |> inspect() |> String.replace(~r/^#PID</, "") |> String.replace(~r/>$/, "")
end
