defmodule ExampleSystemWeb.Top.Dashboard do
  use Phoenix.LiveView

  @impl Phoenix.LiveView
  def render(assigns), do: ExampleSystemWeb.Top.View.render("dashboard.html", assigns)

  @impl Phoenix.LiveView
  def mount(_session, socket) do
    if socket.connected?, do: measure()
    {:ok, assign(socket, top: top(), output: "")}
  end

  @impl Phoenix.LiveView
  def handle_event("process_info", pid_str, socket),
    do: {:noreply, assign(socket, :output, process_info(:erlang.list_to_pid('<#{pid_str}>')))}

  def handle_event("process_kill", pid_str, socket) do
    Process.exit(:erlang.list_to_pid('<#{pid_str}>'), :kill)
    {:noreply, socket}
  end

  def handle_info({:top, top}, socket) do
    measure()
    {:noreply, assign(socket, top: top)}
  end

  defp measure() do
    me = self()
    Task.start_link(fn -> send(me, {:top, top()}) end)
  end

  defp top() do
    wall_times = LoadControl.SchedulerMonitor.wall_times()

    initial_processes = processes()
    Process.sleep(:timer.seconds(1))

    final_processes =
      Enum.map(
        processes(),
        fn {pid, reds} ->
          prev_reds = Map.get(initial_processes, pid, 0)
          %{pid: pid, reds: reds - prev_reds}
        end
      )

    schedulers_usage = LoadControl.SchedulerMonitor.usage(wall_times) / :erlang.system_info(:schedulers_online)

    total_reds_delta = final_processes |> Stream.map(& &1.reds) |> Enum.sum()

    final_processes
    |> Enum.sort_by(& &1.reds, &>=/2)
    |> Stream.reject(&(&1.pid == self()))
    |> Stream.take(10)
    |> Enum.map(&%{pid: &1.pid, cpu: round(schedulers_usage * 100 * &1.reds / total_reds_delta)})
  end

  defp processes() do
    for {pid, {:reductions, reds}} <- Stream.map(Process.list(), &{&1, Process.info(&1, :reductions)}),
        into: %{},
        do: {stringify_pid(pid), reds}
  end

  defp stringify_pid(pid), do: pid |> inspect() |> String.replace(~r/^#PID</, "") |> String.replace(~r/>$/, "")

  defp process_info(pid) do
    [current_stacktrace(pid), "\n\n", trace_process(pid)]
  end

  defp trace_process(pid) do
    trace =
      Task.async(fn ->
        try do
          :erlang.trace(pid, true, [:call])
        rescue
          ArgumentError ->
            ""
        else
          _ ->
            :erlang.trace_pattern({:_, :_, :_}, true, [:local])
            Process.send_after(self(), :stop_trace, :timer.seconds(1))

            fn ->
              receive do
                {:trace, ^pid, :call, {mod, fun, args}} -> {mod, fun, args}
                :stop_trace -> :stop_trace
              end
            end
            |> Stream.repeatedly()
            |> Stream.take(50)
            |> Stream.take_while(&(&1 != :stop_trace))
            |> Stream.map(fn {mod, fun, args} -> "#{inspect(mod)}.#{fun}(#{inspect_args(args)})" end)
            |> Enum.join("\n\n")
        end
      end)
      |> Task.await()

    [
      "Dynamic trace",
      "------------------",
      trace
    ]
    |> Enum.join("\n")
  end

  defp inspect_args(args),
    do: args |> inspect(limit: 5, pretty: true, width: 30) |> String.replace(~r/^\[/, "") |> String.replace(~r/\]$/, "")

  defp current_stacktrace(pid) do
    case Process.info(pid, :current_stacktrace) do
      nil ->
        ""

      {:current_stacktrace, stacktrace} ->
        [
          "Current stacktrace",
          "------------------"
        ]
        |> Stream.concat(Stream.map(stacktrace, &format_stacktrace_entry/1))
        |> Stream.concat([""])
        |> Enum.join("\n")
    end
  end

  defp format_stacktrace_entry({mod, fun, arity, location}), do: "#{inspect(mod)}.#{fun}/#{arity} #{location(location)}"

  defp location(location) do
    [:file, :line]
    |> Stream.map(&location[&1])
    |> Enum.reject(&is_nil/1)
    |> case do
      [file, line] -> "at #{file}:#{line}"
      _ -> ""
    end
  end
end
