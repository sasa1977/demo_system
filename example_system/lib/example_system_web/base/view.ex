defmodule ExampleSystemWeb.Base.View do
  defmacro __using__(opts) do
    quote do
      use Phoenix.View,
          Keyword.merge(
            [root: "lib/example_system_web/templates", namespace: ExampleSystemWeb],
            unquote(opts)
          )

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]
      import Phoenix.LiveView, only: [live_render: 2, live_render: 3]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import ExampleSystemWeb.Router.Helpers
      import ExampleSystemWeb.ErrorHelpers
      import ExampleSystemWeb.Gettext
    end
  end
end
