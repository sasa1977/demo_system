defmodule LoadControl.Worker do
  def start_link(id),
    do:
      Task.start_link(fn ->
        LoadControl.join_worker()

        try do
          loop(id)
        after
          LoadControl.leave_worker()
        end
      end)

  defp loop(id) do
    :timer.sleep(1000)

    if id <= LoadControl.load() do
      if :rand.uniform() < LoadControl.failure_rate(), do: raise("some error")

      _ = Enum.reduce(1..50, 0, &(&1 + &2))
      LoadControl.Stats.job_processed()
      :erlang.garbage_collect()
      loop(id)
    end
  end

  def child_spec(_),
    do: %{
      id: __MODULE__,
      restart: :transient,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      shutdown: 5000
    }
end
