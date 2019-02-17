defmodule ExampleSystemWeb.MathChannel do
  use Phoenix.Channel

  def join("math", _payload, socket) do
    {:ok, %{}, socket}
  end

  def handle_in("sum", %{"number" => number}, socket) do
    ExampleSystem.Math.sum(number)
    {:reply, :ok, socket}
  end

  def handle_info({:sum, number, sum}, socket) do
    push(socket, "sum", %{number: number, sum: sum})
    {:noreply, socket}
  end
end
