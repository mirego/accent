defmodule Accent.Mixfile do
  use Mix.Project

  @version "1.21.4"

  def project do
    [
      app: :accent,
      version: @version,
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      xref: [exclude: IEx],
      deps: deps(),
      releases: releases(),
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

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Framework
      {:phoenix, "~> 1.4"},
      {:phoenix_html, "~> 3.0"},

      # Plugs
      {:plug_assign, "~> 2.0"},
      {:canada, "~> 2.0.0", override: true},
      {:canary, github: "runhyve/canary"},
      {:corsica, "~> 2.0"},
      {:bandit, "~> 1.0"},
      {:plug, "~> 1.14"},
      {:plug_canonical_host, "~> 2.0"},

      # Database
      {:ecto, "~> 3.2", override: true},
      {:ecto_sql, "~> 3.2"},
      {:ecto_dev_logger, "~> 0.4"},
      {:postgrex, "~> 0.14"},
      {:cloak_ecto, "~> 1.2"},

      # Spelling interop with Java runtime
      {:exile, "~> 0.7"},

      # Cache
      {:cachex, "~> 3.6"},

      # Phoenix data helpers
      {:phoenix_ecto, "~> 4.0"},
      {:scrivener_ecto, "~> 2.0"},
      {:dataloader, "~> 2.0"},

      # GraphQL
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4"},
      {:absinthe_error_payload, "~> 1.0"},

      # Utils
      {:jsone, "~> 1.4"},
      {:mochiweb, "~> 2.18"},
      {:httpoison, "~> 1.1"},
      {:gettext, "~> 0.20.0"},
      {:csv, "~> 2.0"},
      {:php_assoc_map, "~> 3.0"},
      {:jason, "~> 1.2", override: true},
      {:erlsom, "~> 1.5"},
      {:xml_builder, "~> 2.0"},
      {:aws_signature, "~> 0.3"},

      # Auth
      {:ueberauth, "~> 0.10"},
      {:oauth2, "~> 2.0"},
      {:ueberauth_microsoft, "~> 0.21"},
      {:ueberauth_google, "~> 0.6"},
      {:ueberauth_github, "~> 0.7"},
      {:ueberauth_discord, "~> 0.5"},
      {:ueberauth_auth0, "~> 2.0"},
      {:ueberauth_oidc, "~> 0.1.7"},

      # Errors
      {:sentry, "~> 7.0"},

      # Mails
      {:bamboo, "~> 2.3", override: true},
      {:tls_certificate_check, "~> 1.21"},
      {:bamboo_phoenix, "~> 1.0"},
      {:bamboo_smtp, "~> 4.2"},

      # Events handling
      {:oban, "~> 2.13"},

      # Metrics and monitoring
      {:new_relic_agent, "~> 1.27"},
      {:new_relic_absinthe, "~> 0.0"},
      {:telemetry, "~> 1.0", override: true},
      {:telemetry_ui, "~> 4.0"},
      {:ecto_psql_extras, "~> 0.7"},

      # Mock testing
      {:mox, "~> 1.0", only: :test},
      {:mock, "~> 0.3.0", only: :test},
      {:factori, "~> 0.13", only: :test},

      # Google API authentication
      {:goth, "~> 1.4"},

      # Network request
      {:tesla, "~> 1.3"},

      # Dev
      {:dialyxir, "~> 1.0", only: ~w(dev test)a, runtime: false},
      {:credo, ">= 0.0.0", only: ~w(dev test)a},
      {:credo_envvar, "~> 0.1.0", only: ~w(dev test)a, runtime: false},
      {:styler, "~> 0.1", only: ~w(dev test)a, runtime: false},
      {:excoveralls, "~> 0.8", only: :test},
      {:phoenix_live_reload, "~> 1.0", only: :dev}
    ] ++
      system_specific_deps()
  end

  defp system_specific_deps do
    is_apple_arm64 =
      :os.type() === {:unix, :darwin} and
        not List.starts_with?(:erlang.system_info(:system_architecture), ~c"x86_64")

    if is_apple_arm64 do
      []
    else
      [
        {:p1_utils, "1.0.15", override: true},
        {:fast_yaml, github: "processone/fast_yaml", ref: "e789f68895f71b7ad31057177810ca0161bf790e"}
      ]
    end
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
