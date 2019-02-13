defmodule ExampleSystemWeb.LoadView do
  use ExampleSystemWeb, :view

  def render("scripts.html", _params) do
    raw(~s'
      <script>
        LoadController.initialize(#{Jason.encode!(Plug.CSRFProtection.get_csrf_token())})
      </script>
    ')
  end
end
