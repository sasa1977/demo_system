# Demo system

> https://www.youtube.com/watch?v=JvBT4XBdoUE

## Getting started

Requires Erlang, Elixir, and node.js, as specified in the [.tool-versions](./.tool-versions) file.
You can use [asdf](https://github.com/asdf-vm/asdf) for that.

Building:

```
cd example_system
mix deps.get &&
pushd assets &&
npm install &&
popd &&
mix compile
```

Starting for development with live reload:

```
iex -S mix phx.server
```

Then, you can visit the following links:

  - http://localhost:4000
  - http://localhost:4000/load
  - http://localhost:4000/services

## Demo

Building and starting for production (in the background):

```
cd example_system
./rebuild.sh
./_build/prod/rel/system/bin/system start
```

Open the remote console:

```
./_build/prod/rel/system/bin/system remote_console
```

Hot upgrade with no downtime:

```
mix system.upgrade
```

## Docker

You can also run this demo using docker

```
make build # builds the container
make run # starts the container
make connect # starts a local shell
```

Then you can run the same commands:
```
./rebuild.sh # optional, if you want to rebuild
./_build/prod/rel/system/bin/system start

./restart.sh # if you want to restart

./_build/prod/rel/system/bin/system remote_console
```

Debugging commands in remote console:
```
Process.list()
Process.list() |> hd()
Process.list() |> hd() |> Process.info()

# Custom `Runtime` module
Runtime.top()
pid = Runtime.top() |> hd() |> Map.get(:pid)
Process.info(pid, :current_stacktrace)
Runtime.trace(pid)

# Kill it
Process.exit(pid, :kill)
```

To do live upgrade:
```
mix system.upgrade
```

To start a new node:
```
mix system.node2
```
