defmodule Accent.Mixfile do
  use Mix.Project

  def project do
    [
      app: :accent,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Accent, []}, extra_applications: [:logger, :canada]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Framework
      {:phoenix, "~> 1.4"},
      {:phoenix_html, "~> 2.10"},

      # Plugs
      {:plug_assign, "~> 1.0.0"},
      {:canary, "~> 1.1.0"},
      {:corsica, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:cowboy, "~> 2.0", override: true},
      {:plug, "~> 1.7", override: true},

      # Database
      {:ecto, "~> 3.0", override: true},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.14"},

      # Phoenix data helpers
      {:phoenix_ecto, "~> 4.0"},
      {:scrivener_ecto, "~> 2.0"},
      {:dataloader, "~> 1.0"},

      # GraphQL
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4"},

      # Utils
      {:p1_utils, github: "processone/p1_utils", override: true},
      {:fast_yaml, "~> 1.0.0"},
      {:jsone, "~> 1.4"},
      {:mochiweb, "~> 2.18"},
      {:httpoison, "~> 1.1.0"},
      {:gettext, "~> 0.11"},
      {:csv, "~> 2.0"},
      {:php_assoc_map, "~> 0.5"},
      {:jason, "~> 1.0"},

      # Errors
      {:sentry, "~> 7.0"},

      # Mails
      {:bamboo, "~> 0.8"},
      {:bamboo_smtp, "~> 1.4.0"},

      # Events handling
      {:gen_stage, "~> 0.11"},

      # Mock testing
      {:mox, "~> 0.3", only: :test},
      {:mock, "~> 0.3.0", only: :test},

      # Dev
      {:dialyxir, "~> 0.5", only: ~w(dev test)a, runtime: false},
      {:credo, ">= 0.0.0", only: ~w(dev test)a},
      {:credo_envvar, "~> 0.1.0", only: ~w(dev test)a, runtime: false},
      {:excoveralls, "~> 0.8", only: :test},
      {:phoenix_live_reload, "~> 1.0", only: :dev},

      # OTP Release
      {:distillery, "~> 2.0", runtime: false}
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
