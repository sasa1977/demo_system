defmodule Mix.Tasks.System.Upgrade do
  # Mix.Task behaviour is not in PLT since Mix is not a runtime dep, so we disable the warning
  @dialyzer :no_undefined_callbacks

  use Mix.Task

  def run(_args) do
    Node.start(:"upgrader@127.0.0.1")
    Node.set_cookie(:super_secret)
    Node.connect(:"node1@127.0.0.1")

    Enum.each(
      [ExampleSystemWeb.Math.Sum, ExampleSystem.Math],
      fn module ->
        :ok =
          File.cp!(
            "_build/prod/lib/example_system/ebin/#{module}.beam",
            "_build/prod/rel/system/lib/example_system-0.0.1/ebin/#{module}.beam"
          )

        {:reloaded, ^module, [^module]} = :rpc.call(:"node1@127.0.0.1", IEx.Helpers, :r, [module])
      end
    )

    Mix.Shell.IO.info("Upgrade finished successfully.")
  end
end
