defmodule Accent.Mixfile do
  use Mix.Project

  @version "1.31.0"

  def project do
    [
      app: :accent,
      version: @version,
      elixir: "~> 1.19",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      elixirc_options: [no_warn_undefined: [IEx]],
      deps: deps(),
      releases: releases(),
      listeners: [Phoenix.CodeReloader],
      dialyzer: [
        list_unused_filters: true,
        plt_add_apps: [:ex_unit]
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Accent, []}, extra_applications: [:logger, :canada, :yamerl]]
  end

  def cli do
    [preferred_envs: [ci: :test]]
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
      {:phoenix_html, "~> 4.3"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_live_view, "~> 1.0"},

      # Plugs
      {:plug_assign, "~> 2.0"},
      {:canada, "~> 2.0.0", override: true},
      {:canary, github: "runhyve/canary"},
      {:corsica, "~> 2.0"},
      {:bandit, "~> 1.0"},
      {:plug, "~> 1.14"},
      {:plug_canonical_host, "~> 2.0"},

      # Database
      {:ecto, "~> 3.14", override: true},
      {:ecto_sql, "~> 3.2"},
      {:ecto_dev_logger, "~> 0.4"},
      {:postgrex, "~> 0.14"},
      {:cloak_ecto, "~> 1.2"},

      # Cache
      {:cachex, "~> 4.1"},

      # Phoenix data helpers
      {:phoenix_ecto, "~> 4.0"},
      {:scrivener_ecto, "~> 3.1"},
      {:dataloader, "~> 2.0"},

      # GraphQL
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4"},
      {:absinthe_error_payload, "~> 1.0"},
      {:absinthe_security, "~> 0.1"},

      # Utils
      {:jsone, "~> 1.4"},
      {:mochiweb, "~> 3.0"},
      {:expo, "~> 1.1"},
      {:csv, "~> 3.2"},
      {:php_assoc_map, "~> 3.0"},
      {:jason, "~> 1.2", override: true},
      {:erlsom, "~> 1.5"},
      {:xml_builder, "~> 2.0"},
      {:yamerl, "~> 0.10"},
      {:ymlr, "~> 5.0"},
      {:aws_signature, "~> 0.3"},
      {:gen_smtp, "~> 1.3", override: true},

      # Auth
      {:ueberauth, "~> 0.11", override: true},
      {:oauth2, "~> 2.0"},
      {:ueberauth_microsoft, "~> 0.21"},
      {:ueberauth_google, "~> 0.6"},
      {:ueberauth_github, "~> 0.7"},
      {:ueberauth_discord, "~> 0.5"},
      {:ueberauth_auth0, "~> 2.0"},
      {:ueberauth_oidcc, "~> 0.4.2"},

      # Errors
      {:sentry, "~> 14.0"},

      # Mails
      {:bamboo, "~> 2.3", override: true},
      {:tls_certificate_check, "~> 1.21"},
      {:bamboo_phoenix, "~> 1.0"},
      {:bamboo_smtp, "~> 4.2"},

      # Events handling
      {:oban, "~> 2.13"},

      # Metrics and monitoring
      {:new_relic_agent, "~> 1.27"},
      {:telemetry, "~> 1.0"},
      {:telemetry_ui, "~> 5.4"},
      {:ecto_psql_extras, "~> 0.7"},

      # OpenTelemetry
      {:opentelemetry_api, "~> 1.4"},
      {:opentelemetry, "~> 1.5"},
      {:opentelemetry_exporter, "~> 1.8"},
      {:opentelemetry_phoenix, "~> 2.0"},
      {:opentelemetry_bandit, "~> 0.2"},
      {:opentelemetry_ecto, "~> 1.2"},
      {:opentelemetry_oban, "~> 1.1"},
      {:opentelemetry_req, "~> 1.0"},
      {:opentelemetry_absinthe, "~> 2.4"},
      {:opentelemetry_dataloader, "~> 0.1"},
      {:opentelemetry_process_propagator, "~> 0.3"},

      # Mock testing
      {:mox, "~> 1.0", only: :test},
      {:factori, "~> 0.13", only: :test},

      # Google API authentication
      {:goth, "~> 1.4"},

      # Network request
      {:req, "~> 0.7"},

      # Dev
      {:dialyxir, "~> 1.0", only: ~w(dev test)a, runtime: false},
      {:credo, ">= 0.0.0", only: ~w(dev test)a},
      {:credo_envvar, "~> 0.1.0", only: ~w(dev test)a, runtime: false},
      {:ex_dna, "~> 1.5", only: ~w(dev test)a, runtime: false},
      {:ex_slop, "~> 0.4", only: ~w(dev test)a, runtime: false},
      {:reach, "~> 2.8", only: ~w(dev test)a, runtime: false},
      {:styler, "~> 1.0", only: ~w(dev test)a, runtime: false},
      {:excoveralls, "~> 0.8", only: :test},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:tidewave, "~> 0.5", only: :dev}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      ci: [
        "compile --warnings-as-errors",
        "format --check-formatted",
        "test",
        "credo --strict",
        "dialyzer",
        "ex_dna --max-clones 0",
        "reach.check --arch --smells"
      ]
    ]
  end

  defp releases do
    [
      accent: [
        version: @version,
        applications: [opentelemetry_exporter: :permanent, opentelemetry: :temporary, accent: :permanent]
      ]
    ]
  end
end
