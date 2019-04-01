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
        {:ok, pid} = ExampleSystem.Math.sum(number)
        operation = %{pid: pid, number: number, sum: :calculating}
        {:noreply, socket |> update(:operations, &[operation | &1]) |> assign(:data, data())}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_info({:sum, pid, sum}, socket),
    do: {:noreply, update(socket, :operations, &set_result(&1, pid, sum))}

  def handle_info({:DOWN, _ref, :process, pid, _reason}, socket),
    do: {:noreply, update(socket, :operations, &set_result(&1, pid, :error))}

  defp set_result(operations, pid, result) do
    case Enum.split_with(operations, &match?(%{pid: ^pid, sum: :calculating}, &1)) do
      {[operation], rest} -> [%{operation | sum: result} | rest]
      _other -> operations
    end
  end

  defp data(), do: Ecto.Changeset.cast({%{}, %{to: :integer}}, %{to: ""}, [:to])
end
