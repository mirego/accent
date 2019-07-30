import Config

version = Mix.Project.config()[:version]

config :accent,
  ecto_repos: [Accent.Repo],
  version: version

config :accent, Accent.Endpoint,
  render_errors: [accepts: ~w(json)],
  pubsub: [name: Accent.PubSub, adapter: Phoenix.PubSub.PG2]

config :accent,
  hook_broadcaster: Accent.Hook.Broadcaster,
  hook_github_file_server: Accent.Hook.Consumers.GitHub.FileServer.HTTP

config :accent, Accent.WebappView, path: "priv/static/webapp/index.html"

config :absinthe, :schema, Accent.GraphQL.Schema

config :canary,
  repo: Accent.Repo,
  unauthorized_handler: {Accent.ErrorController, :handle_unauthorized},
  not_found_handler: {Accent.ErrorController, :handle_not_found}

config :phoenix, :json_library, Jason

config :sentry,
  included_environments: [:prod],
  root_source_code_path: File.cwd!(),
  release: version

config :ueberauth, Ueberauth, providers: []

import_config "#{Mix.env()}.exs"
