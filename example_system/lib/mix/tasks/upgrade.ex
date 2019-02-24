defmodule Mix.Tasks.ExampleSystem.Upgrade do
  # Mix.Task behaviour is not in PLT since Mix is not a runtime dep, so we disable the warning
  @dialyzer :no_undefined_callbacks

  use Mix.Task

  def run(_args) do
    Node.start(:"debugger@127.0.0.1")
    Node.set_cookie(:super_secret)
    Node.connect(:"node1@127.0.0.1")

    :ok =
      File.cp!(
        "_build/prod/lib/example_system/ebin/Elixir.ExampleSystem.Math.beam",
        "_build/prod/rel/node1/lib/example_system-0.0.1/ebin/Elixir.ExampleSystem.Math.beam"
      )

    {:reloaded, ExampleSystem.Math, [ExampleSystem.Math]} =
      :rpc.call(:"node1@127.0.0.1", IEx.Helpers, :r, [ExampleSystem.Math])
  end
end
