use Mix.Config

config :accent, Accent.Endpoint,
  check_origin: false,
  server: true,
  root: ".",
  cache_static_manifest: "priv/static/cache_manifest.json"

config :accent, dummy_provider_enabled: System.get_env("DUMMY_LOGIN_ENABLED")

config :logger, level: :info
