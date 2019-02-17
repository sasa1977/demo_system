defmodule ExampleSystemWeb.MathController do
  use ExampleSystemWeb, :controller

  def index(conn, _params), do: render(conn, "index.html", result: nil)
end
