import Config

config :accent, Accent.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  url: System.get_env("DATABASE_URL") || "postgres://localhost/accent_test"

config :accent, hook_github_file_server: Accent.Hook.Inbounds.GitHub.FileServerMock

config :ueberauth, Ueberauth, providers: [{:dummy, {Accent.Auth.Ueberauth.DummyStrategy, []}}]

config :accent, Oban, crontab: false, queues: false, plugins: false

events = ~w(sync merge create_collaborator create_comment)

config :accent, Accent.Hook,
  outbounds: [{Accent.Hook.Outbounds.Mock, events: events}],
  inbounds: [{Accent.Hook.Inbounds.Mock, events: events}]

config :goth, disabled: true
config :tesla, logger_enabled: false, adapter: Tesla.Mock

config :logger, level: :warn
