defmodule Mix.Tasks.ExampleSystem.Node2 do
  # Mix.Task behaviour is not in PLT since Mix is not a runtime dep, so we disable the warning
  @dialyzer :no_undefined_callbacks

  use Mix.Task

  def run(_args) do
    Node.start(:"node2@127.0.0.1")
    Node.set_cookie(:example_system)
    Node.connect(:"example_system@127.0.0.1")
    System.put_env("PORT", "4001")
    Mix.Task.run("phx.server")
  end
end
