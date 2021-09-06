# Demo system

> https://www.youtube.com/watch?v=JvBT4XBdoUE

## Getting started

Requires Erlang, Elixir, and node.js, as specified in the [.tool-versions](./.tool-versions) file.
You can use [asdf](https://github.com/asdf-vm/asdf) for that.

`load_control` folder is a library directly being used by the `example_system` mix project, which is
the demo app.

Building:

```
cd example_system
mix deps.get &&
pushd assets &&
npm install &&
popd &&
mix compile
```

Starting for development with live reload (recommended for following with youtube):

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

# Processes structure overview

## Load

### Application start
1. `ExampleSystem.Metrics.init/1`
  - calls `LoadControl.subscribe_to_stats/0`
2. `LoadControl.subscribe_to_stats/0`
  - is a `defdelegate` to `LoadControl.Stats.subscribe/0`
3. `LoadControl.Stats.subscribe/0`
  - stores `LoadControl` pid to its subscribers list in state
  - because this was called via `defdelegate`, this function is viewed as if a public function of `LoadControl`

### Routing to `/load` in browser
1. `ExampleSystemWeb.Load.Dashboard.mount/3`
  - calls `ExampleSystem.Metrics.subscribe/0`
2. `ExampleSystem.Metrics.subscribe/0`
  - gets the calling pid (Dashboard LiveView), stores into its list of subscribes in state
