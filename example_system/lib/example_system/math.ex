defmodule ExampleSystem.Math do
  def child_spec(_), do: Supervisor.child_spec(Task.Supervisor.child_spec(name: __MODULE__), id: __MODULE__)

  def sync_sum(number) do
    {:ok, pid} = sum(number)

    receive do
      {:sum, ^pid, result} -> {:ok, result}
      {:DOWN, _mref, :process, ^pid, _reason} -> :error
    after
      100 -> :timeout
    end
  end

  def sum(number) do
    caller = self()

    with {:ok, pid} <-
           Task.Supervisor.start_child(
             __MODULE__,
             fn -> send(caller, {:sum, self(), calc_sum(number)}) end
           ) do
      Process.monitor(pid)
      {:ok, pid}
    end
  end

  defp calc_sum(13) do
    Process.sleep(5000)
    raise("error")
  end

  defp calc_sum(x), do: calc_sum(1, x, 0)

  defp calc_sum(from, from, sum), do: sum + from
  defp calc_sum(from, to, acc_sum), do: calc_sum(from + 1, to, acc_sum + from)
end
