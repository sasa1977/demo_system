use Mix.Config

config :example_system, ExampleSystemWeb.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  http: [transport_options: [num_acceptors: 5]],
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :example_system, ExampleSystemWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/example_system_web/.*\.(eex|leex|ex)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
