use Mix.Config

defmodule Utilities do
  def string_to_boolean("true"), do: true
  def string_to_boolean("1"), do: true
  def string_to_boolean(_), do: false
end

# Used to extract schema json with the absinthe’s mix task
config :absinthe, :schema, Accent.GraphQL.Schema

# Configures the endpoint
config :accent, Accent.Endpoint,
  root: Path.expand("..", __DIR__),
  http: [port: System.get_env("PORT")],
  url: [host: System.get_env("CANONICAL_HOST") || "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [accepts: ~w(json)],
  pubsub: [name: Accent.PubSub, adapter: Phoenix.PubSub.PG2]

# Configure your database
config :accent, :ecto_repos, [Accent.Repo]

config :accent, Accent.Repo,
  adapter: Ecto.Adapters.Postgres,
  timeout: 30_000,
  url: System.get_env("DATABASE_URL") || "postgres://localhost/accent_development"

config :accent,
  force_ssl: Utilities.string_to_boolean(System.get_env("FORCE_SSL")),
  hook_broadcaster: Accent.Hook.Broadcaster,
  dummy_provider_enabled: true,
  restricted_domain: System.get_env("RESTRICTED_DOMAIN")

# Configures canary custom handlers and repo
config :canary,
  repo: Accent.Repo,
  unauthorized_handler: {Accent.ErrorController, :handle_unauthorized},
  not_found_handler: {Accent.ErrorController, :handle_not_found}

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure Phoenix
config :phoenix, Accent.Router, host: System.get_env("CANONICAL_HOST")
config :phoenix, :json_library, Jason

config :phoenix, :generators,
  migration: true,
  binary_id: false

# Configures sentry to report errors
config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: System.get_env("SENTRY_ENVIRONMENT_NAME") || Mix.env(),
  included_environments: [:prod],
  root_source_code_path: File.cwd!()

# Configure mailer
import_config "mailer.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
