defmodule ExampleSystem.Service do
  use GenServer

  def start_distributed(name),
    do: Swarm.register_name(name, __MODULE__, :start_link, [name])

  def invoke(name),
    do: GenServer.call(Swarm.whereis_name(name), :invoke)

  def start_link(name), do: GenServer.start_link(__MODULE__, name)

  @impl GenServer
  def init(name), do: {:ok, %{name: name}}

  @impl GenServer
  def handle_call(:invoke, _from, state),
    do: {:reply, "#{state.name}: #{:rand.uniform()}", state}
end
