defmodule Accent.Mixfile do
  use Mix.Project

  @version "1.6.3"

  def project do
    [
      app: :accent,
      version: @version,
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: extra_compilers(Mix.env()) ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      xref: [exclude: IEx],
      deps: deps(),
      releases: releases(),
      erlc_paths: ["src", "gen"],
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
  defp elixirc_paths(:test), do: ["lib", "web", "vendor", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web", "vendor"]

  defp extra_compilers(:prod), do: [:phoenix]
  defp extra_compilers(_), do: [:gleam, :phoenix]

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
      {:plug, "1.10.4", override: true},

      # Database
      {:ecto, "~> 3.2", override: true},
      {:ecto_sql, "~> 3.2"},
      {:postgrex, "~> 0.14"},

      # Phoenix data helpers
      {:phoenix_ecto, "~> 4.0"},
      {:scrivener_ecto, "~> 2.0"},
      {:dataloader, "~> 1.0"},

      # GraphQL
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4"},
      {:absinthe_error_payload, "~> 1.0"},

      # Utils
      {:p1_utils, "1.0.15", override: true},
      {:fast_yaml, github: "processone/fast_yaml", ref: "e789f68895f71b7ad31057177810ca0161bf790e"},
      {:jsone, "~> 1.4"},
      {:mochiweb, "~> 2.18"},
      {:httpoison, "~> 1.1"},
      {:gettext, "~> 0.17"},
      {:csv, "~> 2.0"},
      {:php_assoc_map, "~> 0.5"},
      {:jason, "~> 1.2", override: true},
      {:erlsom, "~> 1.5"},
      {:xml_builder, "~> 2.0"},

      # Auth
      {:oauth2, "~> 2.0", override: true},
      {:ueberauth, "~> 0.6"},
      {:ueberauth_google, "~> 0.6"},
      {:ueberauth_github, "~> 0.7"},
      {:ueberauth_slack, github: "ueberauth/ueberauth_slack", ref: "525594c870f959ab"},
      {:ueberauth_discord, "~> 0.5"},
      {:ueberauth_microsoft, "~> 0.7"},

      # Errors
      {:sentry, "~> 7.0"},

      # Mails
      {:bamboo, "~> 1.0"},
      {:bamboo_smtp, "~> 2.0"},

      # Events handling
      {:oban, "~> 2.0"},

      # Mock testing
      {:mox, "~> 0.3", only: :test},
      {:mock, "~> 0.3.0", only: :test},

      # Gleam
      {:mix_gleam, "~> 0.1", only: [:dev, :test]},
      {:gleam_stdlib, "~> 0.11", only: [:dev, :test]},

      # Google API authentication
      {:goth, "~> 1.1"},

      # Network request
      {:tesla, "~> 1.3"},

      # Dev
      {:dialyxir, "~> 1.0", only: ~w(dev test)a, runtime: false},
      {:credo, ">= 0.0.0", only: ~w(dev test)a},
      {:credo_envvar, "~> 0.1.0", only: ~w(dev test)a, runtime: false},
      {:excoveralls, "~> 0.8", only: :test},
      {:phoenix_live_reload, "~> 1.0", only: :dev}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp releases do
    [
      accent: [
        version: @version,
        applications: [accent: :permanent]
      ]
    ]
  end
end
