[
  import_deps: [:phoenix, :phoenix_live_view],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"],
  line_length: 120,
  locals_without_parens: [
    release: 2,
    set: 1,
    gen: 1,
    gen: 2
  ]
]
