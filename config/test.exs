use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :accent, Accent.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :accent, sql_sandbox: true

config :accent, Accent.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL") || "postgres://localhost/accent_test",
  pool: Ecto.Adapters.SQL.Sandbox

config :accent, Accent.Mailer,
  webapp_host: "http://example.com",
  mailer_from: "accent-test@example.com",
  x_smtpapi_header: ~s({"category": ["test", "accent-api-test"]}),
  adapter: Bamboo.TestAdapter

config :accent, hook_broadcaster: Accent.Hook.BroadcasterMock
