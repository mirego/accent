import Config

defmodule Utilities do
  def string_to_boolean("true"), do: true
  def string_to_boolean("1"), do: true
  def string_to_boolean(_), do: false

  def string_to_integer(value) when is_bitstring(value), do: String.to_integer(value)
  def string_to_integer(_), do: nil
end

canonical_url = System.get_env("CANONICAL_URL") || "http://localhost:4000"

static_url =
  if canonical_url do
    uri = URI.parse(canonical_url)

    [
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port
    ]
  else
    nil
  end

config :accent,
  force_ssl: Utilities.string_to_boolean(System.get_env("FORCE_SSL")),
  restricted_domain: System.get_env("RESTRICTED_PROJECT_CREATOR_EMAIL_DOMAIN") || System.get_env("RESTRICTED_DOMAIN")

if config_env() === :test do
  config :accent, Accent.Endpoint,
    http: [port: 4001],
    server: false,
    static_url: [
      port: 80,
      scheme: "http",
      host: "example.com"
    ]
else
  config :accent, Accent.Endpoint,
    http: [port: System.get_env("PORT") || "4000"],
    static_url: static_url
end

config :accent, Accent.Repo,
  pool_size: Utilities.string_to_integer(System.get_env("DATABASE_POOL_SIZE")),
  ssl: Utilities.string_to_boolean(System.get_env("DATABASE_SSL")),
  url: System.get_env("DATABASE_URL") || "postgres://localhost/accent_development"

google_translate_provider = {Accent.MachineTranslations.Adapter.GoogleTranslations, [key: System.get_env("GOOGLE_TRANSLATIONS_SERVICE_ACCOUNT_KEY")]}

translate_list_provider = if System.get_env("GOOGLE_TRANSLATIONS_SERVICE_ACCOUNT_KEY"), do: google_translate_provider, else: nil

translate_text_providers = []

translate_text_providers =
  if System.get_env("GOOGLE_TRANSLATIONS_SERVICE_ACCOUNT_KEY"),
    do: [google_translate_provider | translate_text_providers],
    else: translate_text_providers

config :accent, Accent.MachineTranslations,
  translate_list: translate_list_provider,
  translate_text: translate_text_providers

providers = []
providers = if System.get_env("GOOGLE_API_CLIENT_ID"), do: [{:google, {Ueberauth.Strategy.Google, [scope: "email openid"]}} | providers], else: providers
providers = if System.get_env("SLACK_CLIENT_ID"), do: [{:slack, {Ueberauth.Strategy.Slack, [team: System.get_env("SLACK_TEAM_ID")]}} | providers], else: providers
providers = if System.get_env("GITHUB_CLIENT_ID"), do: [{:github, {Ueberauth.Strategy.Github, [default_scope: "user"]}} | providers], else: providers
providers = if System.get_env("DISCORD_CLIENT_ID"), do: [{:discord, {Ueberauth.Strategy.Discord, [default_scope: "identify email"]}} | providers], else: providers
providers = if System.get_env("MICROSOFT_CLIENT_ID"), do: [{:microsoft, {Ueberauth.Strategy.Microsoft, []}} | providers], else: providers
providers = if System.get_env("DUMMY_LOGIN_ENABLED"), do: [{:dummy, {Accent.Auth.Ueberauth.DummyStrategy, []}} | providers], else: providers

config :ueberauth, Ueberauth, providers: providers

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_API_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_API_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Slack.OAuth,
  client_id: System.get_env("SLACK_CLIENT_ID"),
  client_secret: System.get_env("SLACK_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Discord.OAuth,
  client_id: System.get_env("DISCORD_CLIENT_ID"),
  client_secret: System.get_env("DISCORD_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Microsoft.OAuth,
  client_id: System.get_env("MICROSOFT_CLIENT_ID"),
  client_secret: System.get_env("MICROSOFT_CLIENT_SECRET"),
  tenant_id: System.get_env("MICROSOFT_TENANT_ID")

config :accent, Accent.WebappView,
  path: "priv/static/webapp/index.html",
  sentry_dsn: System.get_env("WEBAPP_SENTRY_DSN") || "",
  skip_subresource_integrity: System.get_env("WEBAPP_SKIP_SUBRESOURCE_INTEGRITY") || false

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: System.get_env("SENTRY_ENVIRONMENT_NAME")

if System.get_env("GOOGLE_TRANSLATIONS_SERVICE_ACCOUNT_KEY") do
  config :goth, json: System.get_env("GOOGLE_TRANSLATIONS_SERVICE_ACCOUNT_KEY")
else
  config :goth, disabled: true
end

config :tesla, logger_enabled: true

if !System.get_env("SENTRY_DSN") do
  config :sentry, included_environments: []
end

config :accent, Accent.Mailer,
  mailer_from: System.get_env("MAILER_FROM"),
  x_smtpapi_header: System.get_env("SMTP_API_HEADER")

cond do
  System.get_env("SENDGRID_API_KEY") ->
    config :accent, Accent.Mailer,
      adapter: Bamboo.SendGridAdapter,
      api_key: System.get_env("SENDGRID_API_KEY")

  System.get_env("MANDRILL_API_KEY") ->
    config :accent, Accent.Mailer,
      adapter: Bamboo.MandrillAdapter,
      api_key: System.get_env("MANDRILL_API_KEY")

  System.get_env("MAILGUN_API_KEY") ->
    config :accent, Accent.Mailer,
      adapter: Bamboo.MailgunAdapter,
      api_key: System.get_env("MAILGUN_API_KEY"),
      domain: System.get_env("MAILGUN_DOMAIN")

  System.get_env("SMTP_ADDRESS") ->
    config :accent, Accent.Mailer,
      adapter: Bamboo.SMTPAdapter,
      server: System.get_env("SMTP_ADDRESS"),
      port: System.get_env("SMTP_PORT"),
      username: System.get_env("SMTP_USERNAME"),
      password: System.get_env("SMTP_PASSWORD")

  config_env() == :test ->
    config :accent, Accent.Mailer,
      mailer_from: "accent-test@example.com",
      x_smtpapi_header: ~s({"category": ["test", "accent-api-test"]}),
      adapter: Bamboo.TestAdapter

  true ->
    config :accent, Accent.Mailer, adapter: Bamboo.LocalAdapter
end
