defmodule ExampleSystemWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :example_system

  socket "/live", Phoenix.LiveView.Socket

  plug Plug.Static, at: "/", from: :example_system, gzip: false, only: ~w(css fonts images js favicon.ico robots.txt)

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_example_system_key",
    signing_salt: "Xl786J7N"

  plug ExampleSystemWeb.Router

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config), do: {:ok, put_in(config[:http][:port], port())}

  defp port() do
    if node() == :"node2@127.0.0.1", do: 4001, else: 4000
  end
end
