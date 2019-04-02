defmodule ExampleSystemWeb.Router do
  use Phoenix.Router
  import Plug.Conn
  import Phoenix.Controller
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {ExampleSystemWeb.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExampleSystemWeb do
    pipe_through :browser

    live("/", Math.Sum)
    live("/load", Load.Dashboard)
    live("/services", Services.Dashboard)
    live("/top", Top.Dashboard)
  end
end
