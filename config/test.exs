import Config

import_config "releases.exs"

config :accent, Accent.Endpoint,
  http: [port: 4001],
  server: false

config :accent, Accent.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :accent, Accent.Mailer,
  webapp_url: "http://example.com",
  mailer_from: "accent-test@example.com",
  x_smtpapi_header: ~s({"category": ["test", "accent-api-test"]}),
  adapter: Bamboo.TestAdapter

config :accent,
  hook_broadcaster: Accent.Hook.BroadcasterMock,
  hook_github_file_server: Accent.Hook.Consumers.GitHub.FileServerMock

config :logger, level: :warn
