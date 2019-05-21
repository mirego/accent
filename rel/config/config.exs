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
  version: Application.spec(:accent, :vsn),
  root: Path.expand("..", __DIR__),
  http: [port: System.get_env("PORT") || "4000"],
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
  webapp_url: System.get_env("WEBAPP_URL") || "http://localhost:4000",
  force_ssl: Utilities.string_to_boolean(System.get_env("FORCE_SSL")),
  hook_broadcaster: Accent.Hook.Broadcaster,
  hook_github_file_server: Accent.Hook.Consumers.GitHub.FileServer.HTTP,
  restricted_domain: System.get_env("RESTRICTED_DOMAIN")

# Configures canary custom handlers and repo
config :canary,
  repo: Accent.Repo,
  unauthorized_handler: {Accent.ErrorController, :handle_unauthorized},
  not_found_handler: {Accent.ErrorController, :handle_not_found}

providers = []
providers = if System.get_env("GOOGLE_API_CLIENT_ID"), do: [{:google, {Ueberauth.Strategy.Google, [scope: "email openid"]}} | providers], else: providers
providers = if System.get_env("SLACK_CLIENT_ID"), do: [{:slack, {Ueberauth.Strategy.Slack, [team: System.get_env("SLACK_TEAM_ID")]}} | providers], else: providers
providers = if System.get_env("GITHUB_CLIENT_ID"), do: [{:github, {Ueberauth.Strategy.Github, []}} | providers], else: providers
providers = if System.get_env("DUMMY_LOGIN_ENABLED") || providers === [], do: [{:dummy, {Accent.Auth.Ueberauth.DummyStrategy, []}} | providers], else: providers

config :ueberauth, Ueberauth, providers: providers

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_API_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_API_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Slack.OAuth,
  client_id: System.get_env("SLACK_CLIENT_ID"),
  client_secret: System.get_env("SLACK_CLIENT_SECRET")

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

if !System.get_env("SENTRY_DSN") do
  config :sentry, included_environments: []
end

# Configure mailer
import_config "mailer.exs"
