import Config

import_config "releases.exs"

config :accent, Accent.Endpoint,
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: [
    npm: [
      "run",
      "build-dev",
      cd: Path.expand("../webapp", __DIR__)
    ]
  ],
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

config :phoenix, :stacktrace_depth, 20
