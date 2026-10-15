import Config

alias Accent.HTTPClient

config :accent, Accent.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  url: System.get_env("DATABASE_URL") || "postgres://localhost/accent_test"

config :accent, HTTPClient, plug: {Req.Test, HTTPClient}
config :accent, Oban, crontab: false, testing: :manual

config :goth, disabled: true

config :logger, level: :warning

config :opentelemetry, traces_exporter: :none

config :telemetry_ui, disabled: true

config :ueberauth, Ueberauth, providers: [{:dummy, {Accent.Auth.Ueberauth.DummyStrategy, []}}]
