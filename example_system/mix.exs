defmodule ExampleSystem.Mixfile do
  use Mix.Project

  def project do
    [
      app: :example_system,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [release: :prod, upgrade: :prod],
      aliases: [
        release: ["example_system.build_assets", "phx.digest", "release"],
        upgrade: "example_system.upgrade"
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ExampleSystem.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, github: "phoenixframework/phoenix", branch: "v1.4", override: true},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:ecto, "~> 3.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:recon, "~> 2.0"},
      {:distillery, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:swarm, "~> 3.0"},
      {:load_control, path: "../load_control"},
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},
      {:parent, "~> 0.6"},
      {:stream_data, "~> 0.4.3", only: :test},
      {:assertions, "~> 0.13", only: :test}
    ]
  end
end
