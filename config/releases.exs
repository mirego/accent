import Config

defmodule Utilities do
  def string_to_boolean("true"), do: true
  def string_to_boolean("1"), do: true
  def string_to_boolean(_), do: false
end

webapp_url = System.get_env("WEBAPP_URL") || "http://localhost:4000"
static_url = URI.parse(webapp_url)

config :accent,
  webapp_url: webapp_url,
  force_ssl: Utilities.string_to_boolean(System.get_env("FORCE_SSL")),
  restricted_domain: System.get_env("RESTRICTED_DOMAIN")

config :accent, Accent.Endpoint,
  http: [port: System.get_env("PORT") || "4000"],
  static_url: [
    scheme: static_url.scheme,
    host: static_url.host,
    port: static_url.port
  ]

config :accent, Accent.Repo, url: System.get_env("DATABASE_URL") || "postgres://localhost/accent_development"

providers = []
providers = if System.get_env("GOOGLE_API_CLIENT_ID"), do: [{:google, {Ueberauth.Strategy.Google, [scope: "email openid"]}} | providers], else: providers
providers = if System.get_env("SLACK_CLIENT_ID"), do: [{:slack, {Ueberauth.Strategy.Slack, [team: System.get_env("SLACK_TEAM_ID")]}} | providers], else: providers
providers = if System.get_env("GITHUB_CLIENT_ID"), do: [{:github, {Ueberauth.Strategy.Github, [default_scope: "user"]}} | providers], else: providers
providers = if System.get_env("DISCORD_CLIENT_ID"), do: [{:discord, {Ueberauth.Strategy.Discord, [default_scope: "identify email"]}} | providers], else: providers
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

config :accent, Accent.WebappView,
  force_ssl: Utilities.string_to_boolean(System.get_env("FORCE_SSL")),
  api_host: System.get_env("API_HOST"),
  api_ws_host: System.get_env("API_WS_HOST"),
  sentry_dsn: System.get_env("WEBAPP_SENTRY_DSN") || ""

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: System.get_env("SENTRY_ENVIRONMENT_NAME")

if !System.get_env("SENTRY_DSN") do
  config :sentry, included_environments: []
end

config :accent, Accent.Mailer,
  webapp_url: System.get_env("WEBAPP_URL"),
  mailer_from: System.get_env("MAILER_FROM"),
  x_smtpapi_header: System.get_env("SMTP_API_HEADER")

if System.get_env("SPELLING_GATEWAY_API_URL") do
  config :accent, Accent.Lint,
    spelling_gateway: Accent.Lint.Rules.Spelling.LanguageTool,
    spelling_gateway_url: System.get_env("SPELLING_GATEWAY_API_URL")
else
  config :accent, Accent.Lint, spelling_gateway: Accent.Lint.Rules.Spelling.Noop
end

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

  true ->
    config :accent, Accent.Mailer, adapter: Bamboo.LocalAdapter
end
