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

config :accent, hook_github_file_server: Accent.Hook.Inbounds.GitHub.FileServerMock

config :accent, Accent.Lint,
  spelling_gateway: Accent.Lint.Rules.Spelling.GatewayMock,
  spelling_gateway_url: "http://language-tool.test"

config :ueberauth, Ueberauth, providers: [{:dummy, {Accent.Auth.Ueberauth.DummyStrategy, []}}]

config :accent, Oban, crontab: false, queues: false

events = ~w(sync merge create_collaborator create_comment)

config :accent, Accent.Hook,
  outbounds: [{Accent.Hook.Outbounds.Mock, events: events}],
  inbounds: [{Accent.Hook.Inbounds.Mock, events: events}]

config :logger, level: :warn
