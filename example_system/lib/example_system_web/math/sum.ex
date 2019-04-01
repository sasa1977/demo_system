defmodule ExampleSystemWeb.Math.Sum do
  use Phoenix.LiveView

  @impl Phoenix.LiveView
  def render(assigns), do: ExampleSystemWeb.Math.View.render("sum.html", assigns)

  @impl Phoenix.LiveView
  def mount(_session, socket), do: {:ok, assign(socket, operations: [], data: data())}

  @impl Phoenix.LiveView
  def handle_event("submit", %{"data" => %{"to" => to}}, socket) do
    case Integer.parse(to) do
      {number, ""} ->
        operation = %{id: make_ref(), number: number, sum: :calculating}
        ExampleSystem.Math.sum(operation.id, operation.number)
        {:noreply, socket |> update(:operations, &[operation | &1]) |> assign(:data, data())}

      _ ->
        {:noreply, socket}
    end
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

  defp data(), do: Ecto.Changeset.cast({%{}, %{to: :integer}}, %{to: ""}, [:to])
end
