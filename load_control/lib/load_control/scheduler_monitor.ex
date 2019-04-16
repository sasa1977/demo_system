defmodule LoadControl.SchedulerMonitor do
  use GenServer, start: {__MODULE__, :start_link, []}

  def start_link(), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def init(_) do
    :erlang.system_flag(:scheduler_wall_time, true)
    enqueue_next()
    {:ok, wall_times()}
  end

  def handle_info(:calc_stats, previous_times) do
    enqueue_next()
    LoadControl.Stats.schedulers_usage(usage(previous_times))
    {:noreply, wall_times()}
  end

  def usage(previous_times) do
    new_times = wall_times()

    {actives, totals} =
      new_times
      |> Enum.filter(fn {id, _} ->
        id <= :erlang.system_info(:schedulers_online) or
          (id >= :erlang.system_info(:schedulers) + 1 and
             id < :erlang.system_info(:schedulers) + 1 + :erlang.system_info(:dirty_cpu_schedulers_online))
      end)
      |> Enum.map(fn {scheduler_id, new_time} -> usage(new_time, Map.fetch!(previous_times, scheduler_id)) end)
      |> Enum.unzip()

    total_processors = :erlang.system_info(:schedulers_online) + :erlang.system_info(:dirty_cpu_schedulers_online)

    min(
      total_processors * Enum.sum(actives) / Enum.sum(totals),
      :erlang.system_info(:schedulers_online)
    )
  end

  defp usage(new_time, previous_time),
    do: {new_time.active - previous_time.active, new_time.total - previous_time.total}

  def wall_times() do
    :erlang.statistics(:scheduler_wall_time)
    |> Enum.map(fn {id, active_time, total_time} -> {id, %{active: active_time, total: total_time}} end)
    |> Enum.into(%{})
  end

  defp enqueue_next(), do: Process.send_after(self(), :calc_stats, 200)
end
