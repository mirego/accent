use Mix.Config

defmodule Utilities do
  def string_to_boolean("true"), do: true
  def string_to_boolean("1"), do: true
  def string_to_boolean(_), do: false
end

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
  timeout: 30000,
  url: System.get_env("DATABASE_URL") || "postgres://localhost/accent_development"

config :phoenix, :format_encoders, "json-api": Poison
config :phoenix, Accent.Router, host: System.get_env("CANONICAL_HOST")

config :accent, force_ssl: Utilities.string_to_boolean(System.get_env("FORCE_SSL"))

config :accent, hook_broadcaster: Accent.Hook.Broadcaster

config :accent, dummy_provider_enabled: true

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :canary,
  repo: Accent.Repo,
  unauthorized_handler: {Accent.ErrorController, :handle_unauthorized},
  not_found_handler: {Accent.ErrorController, :handle_not_found}

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  included_environments: [:prod],
  environment_name: Mix.env(),
  root_source_code_path: File.cwd!()

# Used to extract schema json with the absinthe’s mix task
config :absinthe, :schema, Accent.GraphQL.Schema

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

import_config "mailer.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
