defmodule ExampleSystem.Math do
  def child_spec(_), do: Supervisor.child_spec(Task.Supervisor.child_spec(name: __MODULE__), id: __MODULE__)

  def sum(number) do
    caller = self()
    Task.Supervisor.start_child(__MODULE__, fn -> sum(caller, number) end)
  end

  defp sum(caller, number), do: send(caller, {:sum, number, calc_sum(1, number, 0)})

  defp calc_sum(from, from, sum), do: sum + from
  defp calc_sum(from, to, acc_sum), do: calc_sum(from + 1, to, acc_sum + from)
end
