defmodule ExampleSystemWeb.MetricsChannel do
  use Phoenix.Channel

  def join("metrics", _payload, socket) do
    {:ok, %{points: ExampleSystem.Stats.subscribe()}, socket}
  end

  def handle_info({:metrics, metrics}, socket) do
    push(socket, "update", metrics)
    {:noreply, socket}
  end
end
