import Config

watchers =
  if System.get_env("DISABLE_DEV_WATCHERS") do
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

config :accent, Accent.Repo, url: System.get_env("DATABASE_URL") || "postgres://localhost/accent_development"

config :logger, :console,
  format: "$metadata[$level] $message\n",
  metadata: ~w(current_user graphql_operation hook_service hook_url)a

config :phoenix, :stacktrace_depth, 20
