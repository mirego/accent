import Config

version = Mix.Project.config()[:version]

config :accent,
  ecto_repos: [Accent.Repo],
  version: version

config :accent, Accent.Repo, start_apps_before_migration: [:ssl], stacktrace: true

if config_env() == :dev do
  config :accent, Accent.Repo, log: false
end

if config_env() == :test do
  events = ~w(sync add_translations create_collaborator create_comment complete_review new_conflicts)

  config :accent, Accent.Hook, outbounds: [{Accent.Hook.Outbounds.Mock, events: events}]
else
  config :accent, Accent.Hook,
    outbounds: [
      {Accent.Hook.Outbounds.Discord, events: ~w(sync complete_review new_conflicts)},
      {Accent.Hook.Outbounds.Email, events: ~w(create_collaborator create_comment)},
      {Accent.Hook.Outbounds.Slack, events: ~w(sync complete_review new_conflicts)},
      {Accent.Hook.Outbounds.Websocket,
       events: ~w(sync create_collaborator create_comment complete_review new_conflicts)}
    ]
end

config :accent, Accent.Endpoint,
  render_errors: [accepts: ~w(json)],
  pubsub_server: Accent.PubSub

config :accent, Oban,
  plugins: [Oban.Plugins.Pruner],
  queues: [hook: 10, operations: 10],
  repo: Accent.Repo

config :absinthe, :schema, Accent.GraphQL.Schema

config :canary,
  repo: Accent.Repo,
  unauthorized_handler: {Accent.ErrorController, :handle_unauthorized},
  not_found_handler: {Accent.ErrorController, :handle_not_found}

config :phoenix, :json_library, Jason

config :tesla,
  auth_enabled: true,
  adapter: Tesla.Adapter.Hackney

config :sentry,
  before_send_event: {Accent.Sentry, :before_send},
  release: version

config :ueberauth, Ueberauth, providers: []

import_config "#{Mix.env()}.exs"
