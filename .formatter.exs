[
  inputs: [
    "mix.exs",
    ".formatter.exs",
    ".credo.exs",
    "vendor/language_tool/**/*.ex",
    "{config,lib,test,rel,priv}/**/*.{ex,exs}"
  ],
  plugins: [Styler],
  import_deps: [:ecto, :phoenix],
  line_length: 120
]
