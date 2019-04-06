defmodule Runtime do
  def top(time \\ :timer.seconds(1)) do
    wall_times = LoadControl.SchedulerMonitor.wall_times()
    initial_processes = processes()

    Process.sleep(time)

    final_processes =
      Enum.map(
        processes(),
        fn {pid, reds} ->
          prev_reds = Map.get(initial_processes, pid, 0)
          %{pid: pid, reds: reds - prev_reds}
        end
      )

    schedulers_usage = LoadControl.SchedulerMonitor.usage(wall_times) / :erlang.system_info(:schedulers_online)
    total_reds_delta = final_processes |> Stream.map(& &1.reds) |> Enum.sum()

    final_processes
    |> Enum.sort_by(& &1.reds, &>=/2)
    |> Stream.take(10)
    |> Enum.map(&%{pid: &1.pid, cpu: round(schedulers_usage * 100 * &1.reds / total_reds_delta)})
  end

  defp processes() do
    for {pid, {:reductions, reds}} <- Stream.map(Process.list(), &{&1, Process.info(&1, :reductions)}),
        into: %{},
        do: {pid, reds}
  end

  def trace(pid) do
    Task.async(fn ->
      :erlang.trace(pid, true, [:call])

      try do
        :erlang.trace(pid, true, [:call])
      rescue
        ArgumentError ->
          []
      else
        _ ->
          :erlang.trace_pattern({:_, :_, :_}, true, [:local])
          Process.send_after(self(), :stop_trace, :timer.seconds(1))

          fn ->
            receive do
              {:trace, ^pid, :call, {mod, fun, args}} -> {mod, fun, args}
              :stop_trace -> :stop_trace
            end
          end
          |> Stream.repeatedly()
          |> Stream.take(50)
          |> Enum.take_while(&(&1 != :stop_trace))
      end
    end)
    |> Task.await()
  end
end
