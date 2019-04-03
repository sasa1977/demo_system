defmodule ExampleSystem.Service do
  use GenServer

  def start_in_cluster(name) do
    Swarm.register_name(name, __MODULE__, :start_local, [name])
  end

  def invoke(name) do
    pid = Swarm.whereis_name(name)
    GenServer.call(pid, :invoke)
  end

  def start_local(name), do: GenServer.start_link(__MODULE__, name)

  @impl GenServer
  def init(name), do: {:ok, %{name: name}}

  @impl GenServer
  def handle_call(:invoke, _from, state),
    do: {:reply, "#{state.name}: #{:rand.uniform()}", state}
end
