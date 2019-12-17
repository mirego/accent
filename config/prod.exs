import Config

import_config "releases.exs"

config :accent, Accent.Endpoint,
  check_origin: false,
  server: true

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  level: :info,
  metadata: ~w(request_id)a
