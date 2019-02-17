defmodule LoadControl do
  use GenServer, start: {__MODULE__, :start_link, []}

  def start_link(), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def load(), do: get_value(:current_load)

  defdelegate subscribe_to_stats(), to: LoadControl.Stats, as: :subscribe

  def change_load(desired_load) do
    current_load = load()
    set_value(:current_load, desired_load)

    if desired_load > current_load do
      (current_load + 1)..desired_load
      |> Stream.zip(Stream.cycle(all_nodes()))
      |> Enum.each(&start_worker/1)
    else
      fn ->
        :timer.sleep(1500)
        Enum.each(Process.list(), &:erlang.garbage_collect(&1, type: :major))
      end
      |> Task.async()
      |> Task.await(:infinity)
    end
  end

  def set_failure_rate(desired_failure_rate), do: set_value(:failure_rate, desired_failure_rate)

  def failure_rate(), do: get_value(:failure_rate)

  def join_worker(), do: :ets.update_counter(__MODULE__, :workers_count, 1)

  def leave_worker(), do: :ets.update_counter(__MODULE__, :workers_count, -1)

  def workers_count(), do: get_value(:workers_count)

  def change_schedulers(schedulers) do
    :erlang.system_flag(:schedulers_online, schedulers)
    :erlang.system_flag(:dirty_cpu_schedulers_online, schedulers)
  end

  def init(_) do
    :ets.new(__MODULE__, [:named_table, :public, read_concurrency: true, write_concurrency: true])
    set_value(:workers_count, 0)
    set_value(:current_load, 0)
    set_value(:failure_rate, 0)
    {:ok, nil}
  end

  defp get_value(key) do
    [{^key, value}] = :ets.lookup(__MODULE__, key)
    value
  end

  defp set_value(key, value), do: :rpc.multicall(all_nodes(), :ets, :insert, [__MODULE__, {key, value}], :infinity)

  defp all_nodes(), do: Node.list([:this, :visible])

  defp start_worker({worker_id, target_node}) do
    if target_node == node() do
      LoadControl.Workers.start_worker(worker_id)
    else
      :rpc.cast(target_node, LoadControl.Workers, :start_worker, [worker_id])
    end
  end
end
