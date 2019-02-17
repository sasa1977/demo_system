defmodule ExampleSystemWeb.Router do
  use ExampleSystemWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExampleSystemWeb do
    pipe_through :browser

    get "/", MathController, :index
    get "/sum", MathController, :sum

    scope "/load" do
      get "/", LoadController, :index
      post "/change_load", LoadController, :change_load
      post "/change_failure_rate", LoadController, :change_failure_rate
      post "/change_schedulers", LoadController, :change_schedulers
    end
  end
end
