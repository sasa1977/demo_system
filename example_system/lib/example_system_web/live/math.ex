defmodule ExampleSystemWeb.MathLive do
  use Phoenix.LiveView

  @impl Phoenix.LiveView
  def render(assigns), do: ExampleSystemWeb.MathView.render("index.html", assigns)

  @impl Phoenix.LiveView
  def mount(_session, socket), do: {:ok, assign(socket, number: 0, operations: [])}

  @impl Phoenix.LiveView
  def handle_event("submit", params, socket) do
    operation = %{id: make_ref(), number: String.to_integer(Map.fetch!(params, "number")), sum: :calculating}
    ExampleSystem.Math.sum(operation.id, operation.number)
    {:noreply, socket |> update(:number, &(&1 + 1)) |> update(:operations, &[operation | &1])}
  end

  def handle_info({:sum, operation_id, sum}, socket),
    do: {:noreply, update(socket, :operations, &update_sum(&1, operation_id, sum))}

  defp update_sum(operations, id, sum) do
    Enum.map(
      operations,
      fn
        %{id: ^id} = operation -> %{operation | sum: sum}
        operation -> operation
      end
    )
  end
end
