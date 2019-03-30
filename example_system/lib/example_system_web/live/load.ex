defmodule ExampleSystemWeb.LoadLive do
  use Phoenix.LiveView

  @impl Phoenix.LiveView
  def render(assigns), do: ExampleSystemWeb.LoadView.render("index.html", assigns)

  @impl Phoenix.LiveView
  def mount(_session, socket) do
    {:ok, assign(socket, metrics: ExampleSystem.Metrics.subscribe())}
  end

  @impl Phoenix.LiveView
  def handle_event("change_load", %{"desired" => %{"load" => load}}, socket) do
    load = String.to_integer(load)
    Task.start_link(fn -> LoadControl.change_load(load) end)
    {:noreply, socket}
  end

  def handle_event("change_schedulers", %{"desired" => %{"schedulers" => schedulers}}, socket) do
    schedulers = String.to_integer(schedulers)
    LoadControl.change_schedulers(schedulers)
    {:noreply, socket}
  end

  def handle_event("change_failure_rate", %{"desired" => %{"failure_rate" => failure_rate}}, socket) do
    failure_rate = String.to_integer(failure_rate)
    LoadControl.set_failure_rate(failure_rate / 100)
    {:noreply, socket}
  end

  def handle_info({:metrics, metrics}, socket) do
    {:noreply, assign(socket, :metrics, metrics)}
  end
end
