defmodule ExampleSystemWeb.LoadController do
  use ExampleSystemWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", socket_controller: "load_controller"
  end

  def change_load(conn, %{"desired_load" => desired_load}) when is_integer(desired_load) do
    ExampleSystem.LoadController.change_load(desired_load)
    send_resp(conn, Plug.Conn.Status.code(:ok), "")
  end

  def change_failure_rate(conn, %{"failure_rate" => failure_rate}) when is_number(failure_rate) do
    ExampleSystem.LoadController.set_failure_rate(failure_rate / 100)
    send_resp(conn, Plug.Conn.Status.code(:ok), "")
  end

  def change_schedulers(conn, %{"schedulers" => schedulers}) when is_integer(schedulers) do
    ExampleSystem.LoadController.change_schedulers(schedulers)
    send_resp(conn, Plug.Conn.Status.code(:ok), "")
  end
end
