import Config

config :accent, Accent.Endpoint,
  http: [port: 4001],
  static_url: [
    port: 80,
    scheme: "http",
    host: "example.com"
  ],
  server: false

config :accent, Accent.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :accent, Accent.Mailer,
  mailer_from: "accent-test@example.com",
  x_smtpapi_header: ~s({"category": ["test", "accent-api-test"]}),
  adapter: Bamboo.TestAdapter

config :accent, hook_github_file_server: Accent.Hook.Inbounds.GitHub.FileServerMock

config :ueberauth, Ueberauth, providers: [{:dummy, {Accent.Auth.Ueberauth.DummyStrategy, []}}]

config :accent, Oban, crontab: false, queues: false

events = ~w(sync merge create_collaborator create_comment)

config :accent, Accent.Hook,
  outbounds: [{Accent.Hook.Outbounds.Mock, events: events}],
  inbounds: [{Accent.Hook.Inbounds.Mock, events: events}]

config :logger, level: :warn
