defmodule ExampleSystem.Application do
  use Application

  def start(_type, _args) do
    ExampleSystem.LoadController.change_schedulers(1)

    Supervisor.start_link(
      [
        ExampleSystem.BackendServices,
        ExampleSystemWeb.Endpoint
      ],
      strategy: :one_for_one,
      name: ExampleSystem
    )
  end

  def config_change(changed, _new, removed) do
    ExampleSystemWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
