defmodule ExampleSystem.Metrics do
  use GenServer

  @num_points 600

  def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def subscribe(), do: GenServer.call(__MODULE__, :subscribe)

  def clear_history(), do: GenServer.call(__MODULE__, :clear_history)

  def await_next() do
    receive do
      {:metrics, metrics} -> metrics
    end
  end

  @impl GenServer
  def init(_) do
    LoadControl.subscribe_to_stats()

    {:ok, initial_state()}
  end

  @impl GenServer
  def handle_call(:subscribe, {pid, _ref}, state) do
    Process.monitor(pid)
    {:reply, client_data(state), update_in(state.subscribers, &[pid | &1])}
  end

  def handle_call(:clear_history, _from, state) do
    {:reply, :ok, %{initial_state() | subscribers: state.subscribers}}
  end

  @impl GenServer
  def handle_info({:metrics, entry}, state) do
    state = state |> record_metric(entry) |> calc_scheduler_graph() |> calc_jobs_graph
    client_data = client_data(state)
    Enum.each(state.subscribers, &send(&1, {:metrics, client_data}))
    {:noreply, state}
  end

  def handle_info({:DOWN, _mref, :process, pid, _}, state) do
    {:noreply, update_in(state.subscribers, &Enum.reject(&1, fn subscriber -> subscriber == pid end))}
  end

  defp initial_state() do
    %{
      workers_count: 0,
      schedulers_usages: [0],
      jobs_rates: [0],
      memory_usage: 0,
      load: 0,
      schedulers: 0,
      failure_rate: 0,
      scheduler_graph: nil,
      jobs_graph: nil,
      subscribers: []
    }
  end

  defp client_data(state) do
    state
    |> Map.take(~w/workers_count memory_usage scheduler_graph jobs_graph load schedulers failure_rate/a)
    |> Map.merge(%{schedulers_usage: round(100 * hd(state.schedulers_usages)), jobs_rate: hd(state.jobs_rates)})
  end

  defp record_metric(state, entry) do
    %{
      state
      | workers_count: entry.workers_count,
        schedulers_usages:
          Enum.take([entry.schedulers_usage / entry.scheduler_count | state.schedulers_usages], @num_points),
        jobs_rates: Enum.take([entry.jobs_rate | state.jobs_rates], @num_points),
        memory_usage: entry.memory_usage,
        load: LoadControl.load(),
        schedulers: entry.scheduler_count,
        failure_rate: round(100 * LoadControl.failure_rate())
    }
  end

  defp calc_scheduler_graph(state) do
    data_points =
      state.schedulers_usages
      |> Stream.with_index(1)
      |> Enum.map(fn {usage, pos} -> %{x: (@num_points - pos) / @num_points, y: usage} end)

    legends = Enum.map([0, 25, 50, 75, 100], &%{title: "#{&1}%", at: &1 / 100})

    %{state | scheduler_graph: %{data_points: data_points, legends: legends}}
  end

  defp calc_jobs_graph(state) do
    max_rate = Enum.max(state.jobs_rates)
    order_of_magnitude = if max_rate < 10, do: 1, else: round(:math.pow(10, floor(:math.log10(max_rate)) - 1))
    quantized_max_rate = max(round(max_rate / order_of_magnitude) * order_of_magnitude, 1)
    step = max(quantize(quantized_max_rate / 5, order_of_magnitude), 1)

    data_points =
      state.jobs_rates
      |> Stream.with_index(1)
      |> Enum.map(fn {jobs_rate, pos} -> %{x: (@num_points - pos) / @num_points, y: jobs_rate / max(max_rate, 1)} end)

    legends =
      0
      |> Stream.iterate(&(&1 + step))
      |> Stream.take_while(&(&1 <= max_rate))
      |> Enum.map(&%{title: title(&1), at: &1 / max(max_rate, 1)})

    %{state | jobs_graph: %{data_points: data_points, legends: legends}}
  end

  defp quantize(num, quant), do: round(num / quant) * quant

  defp title(num) when num > 0 and rem(num, 1000) == 0, do: "#{div(num, 1000)}k"
  defp title(num), do: num
end
