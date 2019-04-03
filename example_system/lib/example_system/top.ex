defmodule ExampleSystem.Top do
  use Parent.GenServer

  def start_link(_), do: Parent.GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def subscribe(), do: GenServer.call(__MODULE__, :subscribe)

  @impl GenServer
  def init(_), do: {:ok, %{subscribers: MapSet.new(), top: []}}

  @impl GenServer
  def handle_cast({:top, top}, state) do
    Enum.each(state.subscribers, &send(&1, {:top, top}))
    {:noreply, %{state | top: top}}
  end

  @impl GenServer
  def handle_call(:subscribe, {pid, _ref}, state) do
    unless Parent.GenServer.child?(:top), do: start_top()
    Process.monitor(pid)
    {:reply, state.top, update_in(state.subscribers, &MapSet.put(&1, pid))}
  end

  @impl GenServer
  def handle_info({:DOWN, _mref, :process, pid, _reason}, state),
    do: {:noreply, update_in(state.subscribers, &MapSet.delete(&1, pid))}

  @impl Parent.GenServer
  def handle_child_terminated(:top, _meta, _pid, _reason, state) do
    if MapSet.size(state.subscribers) > 0, do: start_top()
    {:noreply, state}
  end

  defp start_top() do
    Parent.GenServer.start_child(%{
      id: :top,
      start: {Task, :start_link, [&top/0]},
      shutdown: :brutal_kill,
      timeout: :timer.seconds(5)
    })
  end

  defp top() do
    wall_times = LoadControl.SchedulerMonitor.wall_times()

    initial_processes = processes()
    Process.sleep(:timer.seconds(1))

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

    top =
      final_processes
      |> Enum.sort_by(& &1.reds, &>=/2)
      |> Stream.take(10)
      |> Enum.map(&%{pid: &1.pid, cpu: round(schedulers_usage * 100 * &1.reds / total_reds_delta)})

    GenServer.cast(__MODULE__, {:top, top})
  end

  defp processes() do
    for {pid, {:reductions, reds}} <- Stream.map(Process.list(), &{&1, Process.info(&1, :reductions)}),
        into: %{},
        do: {pid, reds}
  end
end
