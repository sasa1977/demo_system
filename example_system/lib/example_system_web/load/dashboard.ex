defmodule ExampleSystemWeb.Load.Dashboard do
  use Phoenix.LiveView

  @impl Phoenix.LiveView
  def render(assigns), do: ExampleSystemWeb.Load.View.render("dashboard.html", assigns)

  @impl Phoenix.LiveView
  def mount(_session, socket) do
    {:ok, assign(socket, metrics: ExampleSystem.Metrics.subscribe(), highlighted: nil)}
  end

  @impl Phoenix.LiveView
  def handle_event("change_load", %{"desired" => %{"load" => load}}, socket) do
    with {load, ""} when load >= 0 <- Integer.parse(load),
         do: Task.start_link(fn -> LoadControl.change_load(load) end)

    {:noreply, socket}
  end

  def handle_event("change_schedulers", %{"desired" => %{"schedulers" => schedulers}}, socket) do
    with {schedulers, ""} when schedulers > 0 <- Integer.parse(schedulers),
         do: LoadControl.change_schedulers(schedulers)

    {:noreply, socket}
  end

  def handle_event("change_failure_rate", %{"desired" => %{"failure_rate" => failure_rate}}, socket) do
    with {failure_rate, ""} when failure_rate >= 0 <- Integer.parse(failure_rate),
         do: LoadControl.set_failure_rate(failure_rate / 100)

    {:noreply, socket}
  end

  def handle_event("highlight_" <> what, _params, socket) do
    highlighted = if socket.assigns.highlighted == what, do: nil, else: what
    {:noreply, assign(socket, :highlighted, highlighted)}
  end

  def handle_info({:metrics, metrics}, socket), do: {:noreply, assign(socket, :metrics, metrics)}
end
