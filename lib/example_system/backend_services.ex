defmodule ExampleSystem.BackendServices do
  def child_spec(_arg), do:
    %{
      id: __MODULE__,
      start: {Supervisor, :start_link, [
        [
          ExampleSystem.Stats,
          ExampleSystem.SchedulerMonitor,
          ExampleSystem.Workers,
          ExampleSystem.LoadController
        ],
        [strategy: :one_for_all, name: __MODULE__]
      ]},
      restart: :permanent,
      shutdown: :infinity,
      type: :supervisor
    }
end
