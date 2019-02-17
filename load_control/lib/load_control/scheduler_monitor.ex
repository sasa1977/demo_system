defmodule LoadControl.SchedulerMonitor do
  use GenServer, start: {__MODULE__, :start_link, []}

  def start_link(), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def init(_) do
    :erlang.system_flag(:scheduler_wall_time, true)
    :timer.send_interval(200, :calc_stats)
    {:ok, schedulers_times()}
  end

  def handle_info(:calc_stats, previous_times) do
    LoadControl.Stats.schedulers_usage(schedulers_usage(schedulers_times(), previous_times))
    {:noreply, schedulers_times()}
  end

  defp schedulers_usage(new_times, previous_times) do
    {actives, totals} =
      new_times
      |> Enum.filter(fn {id, _} ->
        id <= :erlang.system_info(:schedulers_online) or
          (id >= :erlang.system_info(:schedulers) + 1 and
             id < :erlang.system_info(:schedulers) + 1 + :erlang.system_info(:dirty_cpu_schedulers_online))
      end)
      |> Enum.map(fn {scheduler_id, new_time} ->
        scheduler_usage(new_time, Map.fetch!(previous_times, scheduler_id))
      end)
      |> Enum.unzip()

    total_processors = :erlang.system_info(:schedulers_online) + :erlang.system_info(:dirty_cpu_schedulers_online)

    min(
      total_processors * Enum.sum(actives) / Enum.sum(totals),
      :erlang.system_info(:schedulers_online)
    )
  end

  defp scheduler_usage(new_time, previous_time),
    do: {new_time.active - previous_time.active, new_time.total - previous_time.total}

  defp schedulers_times() do
    :erlang.statistics(:scheduler_wall_time)
    |> Enum.map(fn {id, active_time, total_time} -> {id, %{active: active_time, total: total_time}} end)
    |> Enum.into(%{})
  end
end
