import Config

config :accent, Accent.Endpoint,
  check_origin: false,
  server: true

config :accent, Accent.Endpoint, debug_errors: false

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  level: :info,
  metadata: ~w(request_id current_user graphql_operation hook_service hook_url)a
