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

Then, you can visit the following links:

  - http://localhost:4000
  - http://localhost:4000/load
  - http://localhost:4000/services
