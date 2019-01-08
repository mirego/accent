use Mix.Config

config :accent, Accent.Endpoint,
  check_origin: false,
  server: true,
  root: ".",
  cache_static_manifest: "priv/static/cache_manifest.json"

config :accent, dummy_provider_enabled: false

config :logger, level: :info
