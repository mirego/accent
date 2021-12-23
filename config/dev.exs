import Config

watchers = if System.get_env("DISABLE_DEV_WÀTCHERS") do
  []
else
  [
    npm: [
      "run",
      "build-dev",
      cd: Path.expand("../webapp", __DIR__)
    ]
  ]
end

config :accent, Accent.Endpoint,
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: watchers,
  live_reload: [
    patterns: [
      ~r{priv/gettext/.*$},
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$}
    ]
  ]

config :accent, Accent.Hook,
  outbounds: [
    {Accent.Hook.Outbounds.Discord, events: ~w(sync)},
    {Accent.Hook.Outbounds.Email, events: ~w(create_collaborator create_comment)},
    {Accent.Hook.Outbounds.Slack, events: ~w(sync)},
    {Accent.Hook.Outbounds.Websocket, events: ~w(sync create_collaborator create_comment)}
  ],
  inbounds: [{Accent.Hook.Inbounds.GitHub, events: ~w(sync)}]

config :logger, :console,
  format: "$metadata[$level] $message\n",
  metadata: ~w(current_user graphql_operation)a

config :accent, Accent.Repo, url: System.get_env("DATABASE_URL") || "postgres://localhost/accent_development"

config :phoenix, :stacktrace_depth, 20
