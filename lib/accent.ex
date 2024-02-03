defmodule Accent do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Accent.Endpoint,
      Accent.Repo,
      {Oban, oban_config()},
      Accent.Vault,
      {Cachex, name: :language_tool_cache, limit: 10_000},
      {LanguageTool.Server, language_tool_config()},
      {TelemetryUI, Accent.TelemetryUI.config()},
      {Phoenix.PubSub, [name: Accent.PubSub, adapter: Phoenix.PubSub.PG2]}
    ]

    if Application.get_env(:sentry, :dsn) do
      {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)
    end

    if Application.get_env(:accent, Accent.Mailer)[:adapter] === BambooSMTPAdapterWithTlsOptions do
      add_tls_options_to_mailer_smtp_adapter()
    end

    Ecto.DevLogger.install(Accent.Repo,
      ignore_event: fn metadata ->
        not is_nil(metadata[:options][:telemetry_ui_conf])
      end
    )

    opts = [strategy: :one_for_one, name: Accent.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Accent.Endpoint.config_change(changed, removed)
    :ok
  end

  defp add_tls_options_to_mailer_smtp_adapter do
    config = Application.get_env(:accent, Accent.Mailer)
    new_config = Keyword.put(config, :tls_options, :tls_certificate_check.options(config[:server]))
    Application.put_env(:accent, Accent.Mailer, new_config)
  end

  defp language_tool_config do
    [
      languages: Application.get_env(:accent, LanguageTool)[:languages],
      disabled_rule_ids: ~w(UPPERCASE_SENTENCE_START POINTS_2 FRENCH_WHITESPACE DETERMINER_SENT_END)
    ]
  end

  defp oban_config do
    opts = Application.get_env(:accent, Oban)

    # Prevent running queues or scheduling jobs from an iex console.
    if Code.ensure_loaded?(IEx) and IEx.started?() do
      opts
      |> Keyword.put(:crontab, false)
      |> Keyword.put(:queues, false)
    else
      opts
    end
  end
end
