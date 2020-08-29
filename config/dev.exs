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
  ]

config :accent, Accent.Hook,
  outbounds: [
    {Accent.Hook.Outbounds.Discord, events: ~w(sync)},
    {Accent.Hook.Outbounds.Email, events: ~w(create_collaborator create_comment)},
    {Accent.Hook.Outbounds.Slack, events: ~w(sync)},
    {Accent.Hook.Outbounds.Websocket, events: ~w(sync create_collaborator create_comment)}
  ],
  inbounds: [{Accent.Hook.Inbounds.GitHub, events: ~w(sync)}]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
