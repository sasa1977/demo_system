defmodule Mix.Tasks.System.Observer do
  # Mix.Task behaviour is not in PLT since Mix is not a runtime dep, so we disable the warning
  @dialyzer :no_undefined_callbacks

  use Mix.Task

  def run(_args) do
    Node.start(:"observer@127.0.0.1")
    Node.set_cookie(:super_secret)
    Node.connect(:"node1@127.0.0.1")
    :observer.start()
    :timer.sleep(:infinity)
  end
end
