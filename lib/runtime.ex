defmodule Runtime do
  def top_delta(property, time), do:
    Enum.map(
      :recon.proc_window(property, 10, time),
      &%{pid: elem(&1, 0), reductions: elem(&1, 1)}
    )

  def trace_calls(pid, module), do:
    :recon_trace.calls({module, :_, :_}, 100, pid: pid, scope: :local, formatter: &format_trace/1)

  defp format_trace({:trace, _pid, :call, {module, function, args}}), do:
    "#{inspect(module)}.#{function}(#{args |> Enum.map(&inspect/1) |> Enum.intersperse(", ")})\n"
end
