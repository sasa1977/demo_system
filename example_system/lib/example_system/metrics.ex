defmodule ExampleSystem.Metrics do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def subscribe(), do: GenServer.call(__MODULE__, :subscribe)

  @impl GenServer
  def init(_) do
    LoadControl.subscribe_to_stats()

    {:ok,
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
     }}
  end

  @impl GenServer
  def handle_call(:subscribe, {pid, _ref}, state) do
    Process.monitor(pid)
    {:reply, client_data(state), update_in(state.subscribers, &[pid | &1])}
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

  defp client_data(state) do
    state
    |> Map.take(~w/workers_count memory_usage scheduler_graph jobs_graph load schedulers failure_rate/a)
    |> Map.merge(%{schedulers_usage: round(100 * hd(state.schedulers_usages)), jobs_rate: hd(state.jobs_rates)})
  end

  defp record_metric(state, entry) do
    %{
      state
      | workers_count: entry.workers_count,
        schedulers_usages: Enum.take([entry.schedulers_usage / entry.scheduler_count | state.schedulers_usages], 600),
        jobs_rates: Enum.take([entry.jobs_rate | state.jobs_rates], 600),
        memory_usage: entry.memory_usage,
        load: LoadControl.load(),
        schedulers: entry.scheduler_count,
        failure_rate: round(100 * LoadControl.failure_rate())
    }
  end

  defp calc_scheduler_graph(state) do
    points =
      state.schedulers_usages
      |> Stream.with_index(1)
      |> Stream.map(fn {usage, pos} -> "#{600 - pos},#{max(500 - round(500 * usage), 0)}" end)
      |> Enum.join(" ")

    lines = [
      %{title: 0, at: 500},
      %{title: 25, at: 375},
      %{title: 50, at: 250},
      %{title: 75, at: 125},
      %{title: 100, at: 0}
    ]

    graph = %{width: 600, height: 500, lines: lines, points: points}
    %{state | scheduler_graph: graph}
  end

  defp calc_jobs_graph(state) do
    max_rate = Enum.max(state.jobs_rates)
    order_of_magnitude = if max_rate < 10, do: 1, else: round(:math.pow(10, (max_rate |> :math.log10() |> floor()) - 1))
    step = max(quantize(max_rate / 5, order_of_magnitude), 1)
    max_rate = max(quantize(max_rate, step), 1)

    points =
      state.jobs_rates
      |> Stream.with_index(1)
      |> Stream.map(fn {jobs_rate, pos} -> "#{600 - pos},#{500 - round(500 * jobs_rate / max_rate)}" end)
      |> Enum.join(" ")

    lines =
      0
      |> Stream.iterate(&(&1 + step))
      |> Stream.take_while(&(&1 <= max_rate))
      |> Enum.map(&%{title: title(&1), at: 500 - round(500 * &1 / max_rate)})

    graph = %{width: 600, height: 500, lines: lines, points: points}
    %{state | jobs_graph: graph}
  end

  defp quantize(num, quant), do: ceil(num / quant) * quant

  defp title(num) when num > 0 and rem(num, 1000) == 0, do: "#{div(num, 1000)}k"
  defp title(num), do: num
end
