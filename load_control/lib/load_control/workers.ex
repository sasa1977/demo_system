defmodule LoadControl.Workers do
  require Logger

  @shards 1000

  def start_link(),
    do:
      Supervisor.start_link(
        number_producer_supervisors(),
        strategy: :one_for_all,
        name: __MODULE__
      )

  def start_worker(id), do: Supervisor.start_child(supervisor_name(rem(id, @shards) + 1), [id])

  defp number_producer_supervisors(), do: Enum.map(1..@shards, &number_producer_sup/1)

  defp number_producer_sup(id),
    do:
      Supervisor.Spec.supervisor(
        Supervisor,
        [
          [LoadControl.Worker],
          [
            strategy: :simple_one_for_one,
            name: supervisor_name(id),
            max_restarts: 100_000_000,
            max_seconds: 1
          ]
        ],
        id: supervisor_name(id)
      )

  defp supervisor_name(id), do: Module.concat(__MODULE__.Supervisor, :"#{id}")

  def child_spec(_arg),
    do: %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :permanent,
      shutdown: :timer.seconds(5),
      type: :supervisor
    }
end
