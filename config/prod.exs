import Config

import_config "releases.exs"

config :accent, Accent.Endpoint,
  check_origin: false,
  server: true

config :accent, Accent.Hook,
  outbounds: [
    {Accent.Hook.Outbounds.Discord, events: ~w(sync)},
    {Accent.Hook.Outbounds.Email, events: ~w(create_collaborator create_comment)},
    {Accent.Hook.Outbounds.Slack, events: ~w(sync)},
    {Accent.Hook.Outbounds.Websocket, events: ~w(sync create_collaborator create_comment)}
  ],
  inbounds: [{Accent.Hook.Inbounds.GitHub, events: ~w(sync)}]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  level: :info,
  metadata: ~w(request_id)a
