defmodule ExampleSystemWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "metrics", ExampleSystemWeb.MetricsChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
