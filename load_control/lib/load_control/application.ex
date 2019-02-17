defmodule LoadControl.Application do
  use Application

  def start(_type, _args) do
    children = [
      LoadControl.Stats,
      LoadControl.SchedulerMonitor,
      LoadControl.Workers,
      LoadControl
    ]

    opts = [strategy: :one_for_one, name: LoadControl.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
