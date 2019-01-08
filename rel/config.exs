# Import all plugins from `rel/plugins`
~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  default_release: :default,
  default_environment: Mix.env()

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/config/distillery.html

environment :dev do
  set(dev_mode: true)
  set(include_erts: false)
  set(cookie: "_this_is_a_development_only_magic_secret_")
end

environment :prod do
  set(include_erts: true)
  set(include_src: false)
  set(cookie: "${ERLANG_COOKIE}")
end

release :accent do
  set(version: current_version(:accent))

  set(
    applications: [
      :runtime_tools
    ]
  )

  set(
    config_providers: [
      {Mix.Releases.Config.Providers.Elixir, ["${RELEASE_ROOT_DIR}/etc/config.exs"]}
    ]
  )

  set(
    overlays: [
      {:copy, "rel/config/config.exs", "etc/config.exs"},
      {:copy, "rel/config/mailer.exs", "etc/mailer.exs"}
    ]
  )

  set(
    commands: [
      migrate: "rel/commands/migrate.sh"
    ]
  )
end
