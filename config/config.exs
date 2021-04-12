import Config

version = Mix.Project.config()[:version]

config :accent,
  ecto_repos: [Accent.Repo],
  version: version

config :accent, Accent.Repo, timeout: 25_000, start_apps_before_migration: [:ssl]

config :accent, Accent.Endpoint,
  render_errors: [accepts: ~w(json)],
  pubsub_server: Accent.PubSub

config :accent, hook_github_file_server: Accent.Hook.Inbounds.GitHub.FileServer.HTTP

config :accent, Oban, queues: [hook: 10], repo: Accent.Repo

config :absinthe, :schema, Accent.GraphQL.Schema

config :canary,
  repo: Accent.Repo,
  unauthorized_handler: {Accent.ErrorController, :handle_unauthorized},
  not_found_handler: {Accent.ErrorController, :handle_not_found}

config :phoenix, :json_library, Jason

config :tesla,
  auth_enabled: true,
  adapter: Tesla.Adapter.Hackney

config :ueberauth, Ueberauth, providers: []

import_config "#{Mix.env()}.exs"
