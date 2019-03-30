defmodule ExampleSystemWeb.Math.View do
  use ExampleSystemWeb.Base.View, root: "lib/example_system_web"

  defp number_input(_number), do: raw(~s/<input id="number" name="number" type="number" value="" autofocus="true">/)

  defp sum_display(:calculating), do: "calculating"
  defp sum_display(sum) when is_number(sum), do: sum
end
