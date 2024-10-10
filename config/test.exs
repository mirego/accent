import Config

config :accent, Accent.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  url: System.get_env("DATABASE_URL") || "postgres://localhost/accent_test"

config :accent, Oban, crontab: false, testing: :manual

config :goth, disabled: true

config :logger, level: :warning

config :telemetry_ui, disabled: true

config :tesla, logger_enabled: false, adapter: Tesla.Mock

config :ueberauth, Ueberauth, providers: [{:dummy, {Accent.Auth.Ueberauth.DummyStrategy, []}}]
