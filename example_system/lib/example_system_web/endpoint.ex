defmodule ExampleSystemWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :example_system

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    # Make sure session cookies survive a restarted browser
    max_age: 9_999_999_999,
    key: "_example_system_key",
    signing_salt: "JFWrRJY1"
    # encryption_salt: "SALT BAE cookie store encryption salt"
  ]

  socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])

  plug(Plug.Static,
    at: "/",
    from: :example_system,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)
  )

  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  plug(
    Plug.Session,
    @session_options
  )

  plug(ExampleSystemWeb.Router)

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
