defmodule LoadControl.Stats do
  use GenServer, start: {__MODULE__, :start_link, []}

  def start_link(), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def subscribe(), do: Enum.reverse(GenServer.call(__MODULE__, {:subscribe, self()}))

  def job_processed(), do: :ets.update_counter(__MODULE__, :jobs_processed, 1)

  def schedulers_usage(usage), do: set_value(:schedulers_usage, usage)

  def init(_) do
    :ets.new(__MODULE__, [:named_table, :public, write_concurrency: true, read_concurrency: false])
    set_value(:jobs_processed, 0)
    set_value(:schedulers_usage, 0)
    enqueue_next()
    {:ok, %{start: :erlang.monotonic_time(), points: [], subscribers: MapSet.new(), emitted_points: []}}
  end

  def handle_info(:emit_stats, state) do
    enqueue_next()

    new_point = %{
      jobs_rate: jobs_rate(state.start),
      schedulers_usage: value(:schedulers_usage),
      memory_usage: div(:erlang.memory(:total), 1024 * 1024),
      workers_count: LoadControl.workers_count(),
      scheduler_count: :erlang.system_info(:schedulers_online)
    }

    previous_points = Enum.take(state.points, 9)
    length = length(previous_points) + 1

    running_average =
      previous_points
      |> Enum.reduce(new_point, &add_maps/2)
      |> Enum.map(fn {key, value} ->
        avg_value = if key == :schedulers_usage, do: value / length, else: round(value / length)
        {key, avg_value}
      end)
      |> Enum.into(%{node: node()})

    Enum.each(state.subscribers, &send(&1, {:metrics, running_average}))

    now = :erlang.monotonic_time()
    set_value(:jobs_processed, 0)

    {:noreply,
     %{
       state
       | start: now,
         points: [new_point | previous_points],
         emitted_points: Enum.take([running_average | state.emitted_points], 600)
     }}
  end

  def handle_call({:subscribe, subscriber}, _from, state) do
    {:reply, state.emitted_points, update_in(state.subscribers, &MapSet.put(&1, subscriber))}
  end

  defp add_maps(map1, map2),
    do:
      map1
      |> Map.keys()
      |> Enum.map(&{&1, Map.fetch!(map1, &1) + Map.fetch!(map2, &1)})
      |> Enum.into(%{})

  defp jobs_rate(start) do
    count = value(:jobs_processed)

    count
    |> Kernel./(max(:erlang.convert_time_unit(:erlang.monotonic_time() - start, :native, :microsecond), 100_000))
    |> Kernel.*(1_000_000)
    |> trunc()
  end

  defp set_value(key, value), do: :ets.insert(__MODULE__, {key, value})

  defp value(key) do
    [{^key, value}] = :ets.lookup(__MODULE__, key)
    value
  end

  defp enqueue_next(), do: Process.send_after(self(), :emit_stats, 100)
end
