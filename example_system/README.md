Requires Erlang, Elixir, and node.js, as specified in the [.tool-versions](./.tool-versions) file.

Building:

```
cd example_system
mix deps.get &&
pushd assets &&
npm install &&
popd &&
mix compile
```

Starting:

```
iex -S mix phx.server
```

The you can visit the main page at localhost:4000, and the load control page at localhost:4000/load.
