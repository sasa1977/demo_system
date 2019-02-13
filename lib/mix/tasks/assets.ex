defmodule Mix.Tasks.ExampleSystem.BuildAssets do
  @shortdoc "Builds the site assets for production."
  @moduledoc false

  # Mix.Task behaviour is not in PLT since Mix is not a runtime dep, so we disable the warning
  @dialyzer :no_undefined_callbacks

  use Mix.Task

  def run(_args) do
    cmd!(
      "node",
      [Path.join(~w(node_modules webpack bin webpack.js)), "--mode", "production"],
      cd: "assets"
    )
  end

  defp cmd!(cmd, args, opts) do
    case System.cmd(cmd, args, opts) do
      {output, 0} ->
        Mix.shell().info(output)

      {output, exit_status} ->
        [output, "`#{cmd} #{Enum.join(args, " ")}` returned #{exit_status}"]
        |> Enum.join("\n")
        |> Mix.raise()
    end
  end
end
