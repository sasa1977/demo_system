defmodule ExampleSystem.Service do
  alias ExampleSystem.Service.Local

  def start_link(), do: DynamicSupervisor.start_link(strategy: :one_for_one, name: __MODULE__)

  def start_in_cluster(name) do
    Swarm.register_name(name, __MODULE__, :start_local, [])
  end

  def invoke(name) do
    pid = Swarm.whereis_name(name)
    Local.invoke(pid)
  end

  def start_local(), do: DynamicSupervisor.start_child(__MODULE__, Local)

  def child_spec(_) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, []}}
  end

  defmodule Local do
    use GenServer

    def start_link(_), do: GenServer.start_link(__MODULE__, nil)

    def invoke(pid), do: GenServer.call(pid, :invoke)

    @impl GenServer
    def init(nil), do: {:ok, %{id: 1}}

    @impl GenServer
    def handle_call(:invoke, _from, state),
      do: {:reply, "response ##{state.id}", update_in(state.id, &(&1 + 1))}
  end
end
