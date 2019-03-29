defmodule ExampleSystem.Math do
  def child_spec(_), do: Supervisor.child_spec(Task.Supervisor.child_spec(name: __MODULE__), id: __MODULE__)

  def sum(operation_id, number) do
    caller = self()
    Task.Supervisor.start_child(__MODULE__, fn -> sum(caller, operation_id, number) end)
  end

  defp sum(caller, operation_id, number), do: send(caller, {:sum, operation_id, calc_sum(1, number, 0)})

  defp calc_sum(from, from, sum), do: sum + from
  defp calc_sum(from, to, acc_sum), do: calc_sum(from + 1, to, acc_sum + from)
end
