defmodule Accent.Mixfile do
  use Mix.Project

  def project do
    [
      app: :accent,
      version: "0.0.1",
      elixir: "~> 1.6.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: [extras: ["API_DOC.md"]],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Accent, []}, extra_applications: [:jiffy, :logger, :canada]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Release
      {:distillery, "~> 2.0"},

      # Framework
      {:phoenix, "~> 1.3"},
      {:phoenix_html, "~> 2.10"},
      {:postgrex, "~> 0.13"},

      # Plugs
      {:plug_assign, "~> 1.0.0"},
      {:plug, "~> 1.4", override: true},
      {:canary, "~> 1.1.0"},
      {:corsica, "~> 1.0"},

      # Phoenix data helpers
      {:ecto, "~> 2.2", override: true},
      {:phoenix_ecto, "~> 3.2", override: true},
      {:scrivener_ecto, "~> 1.0"},
      {:dataloader, "~> 1.0"},

      # GraphQL
      {:absinthe, "~> 1.4.13"},
      {:absinthe_plug, "~> 1.4"},

      # Utils
      {:p1_utils, github: "processone/p1_utils", override: true},
      {:fast_yaml, "~> 1.0.0"},
      {:jiffy, github: "davisp/jiffy"},
      {:mochiweb_html, "~> 2.13"},
      {:httpoison, "~> 1.1.0"},
      {:gettext, "~> 0.11"},
      {:csv, "~> 2.0"},
      {:php_assoc_map, "~> 0.5"},

      # Errors
      {:sentry, "~> 6.0"},

      # Mails
      {:bamboo, "~> 0.8"},
      {:bamboo_smtp, "~> 1.4.0"},

      # Events handling
      {:gen_stage, "~> 0.11"},

      # Mock testing
      {:mox, "~> 0.3"},
      {:mock, "~> 0.3.0", only: :test},

      # Dev
      {:dialyxir, "~> 0.5", only: ~w(dev test)a, runtime: false},
      {:credo, ">= 0.0.0", only: ~w(dev test)a},
      {:excoveralls, "~> 0.8", only: :test},
      {:phoenix_live_reload, "~> 1.0", only: :dev}
    ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
