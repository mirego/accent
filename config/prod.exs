use Mix.Config

config :accent, dummy_provider_enabled: false

config :accent, Accent.Endpoint, check_origin: false,
  http: [port: "${PORT}"],
  url: [host: "localhost", port: "${PORT}"], # This is critical for ensuring web-sockets properly authorize.
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Application.spec(:accent, :vsn)

config :logger, level: :info
