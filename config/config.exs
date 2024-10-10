import Config

version = Mix.Project.config()[:version]

config :accent, Accent.Repo, start_apps_before_migration: [:ssl], stacktrace: true

config :accent,
  ecto_repos: [Accent.Repo],
  version: version

if config_env() == :dev do
  config :accent, Accent.Repo, log: false
end

if config_env() == :test do
  config :accent, Accent.Hook, outbounds: [Accent.Hook.Outbounds.Mock]
else
  config :accent, Accent.Hook,
    outbounds: [
      Accent.Hook.Outbounds.Discord,
      Accent.Hook.Outbounds.Email,
      Accent.Hook.Outbounds.Slack,
      Accent.Hook.Outbounds.Websocket
    ]
end

config :absinthe, :schema, Accent.GraphQL.Schema

config :accent, Accent.Endpoint,
  render_errors: [accepts: ~w(json)],
  pubsub_server: Accent.PubSub

config :accent, Oban,
  plugins: [Oban.Plugins.Pruner],
  queues: [hook: 10, operations: 10],
  repo: Accent.Repo

config :canary,
  repo: Accent.Repo,
  unauthorized_handler: {Accent.ErrorController, :handle_unauthorized},
  not_found_handler: {Accent.ErrorController, :handle_not_found}

config :phoenix, :json_library, Jason

config :sentry,
  before_send_event: {Accent.Sentry, :before_send},
  release: version

config :tesla,
  auth_enabled: true,
  adapter: Tesla.Adapter.Hackney

config :ueberauth, Ueberauth, providers: []

import_config "#{Mix.env()}.exs"
