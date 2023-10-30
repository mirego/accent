import Accent.Config
import Config

port = get_env("PORT", :integer) || 4000
canonical_uri = get_env("CANONICAL_URL", :uri) || parse_env("http://localhost:#{port}", :uri)
static_uri = get_env("STATIC_URL", :uri) || canonical_uri

if config_env() === :test do
  config :accent, Accent.Endpoint,
    http: [port: 4001],
    server: false,
    url: [port: 80, scheme: "http", host: "example.com"],
    static_url: [port: 80, scheme: "http", host: "example.com"]

  config :accent,
    canonical_host: nil,
    force_ssl: false,
    restricted_domain: nil
else
  config :accent,
    canonical_host: get_uri_part(canonical_uri, :host),
    force_ssl: get_uri_part(canonical_uri, :scheme) === "https",
    restricted_domain: get_env("RESTRICTED_PROJECT_CREATOR_EMAIL_DOMAIN") || get_env("RESTRICTED_DOMAIN")

  config :accent, Accent.Endpoint,
    http: [port: port],
    url: get_endpoint_url_config(canonical_uri),
    static_url: get_endpoint_url_config(static_uri),
    debug_errors: get_env("DEBUG_ERRORS", :boolean)
end

ecto_ipv6? = get_env("ECTO_IPV6", :boolean)

config :accent, Accent.Repo,
  timeout: get_env("DATABASE_TIMEOUT", :integer) || 29_000,
  queue_target: get_env("DATABASE_QUEUE_TARGET", :integer) || 500,
  queue_interval: get_env("DATABASE_QUEUE_INTERVAL", :integer) || 2000,
  pool_size: get_env("DATABASE_POOL_SIZE", :integer),
  ssl: get_env("DATABASE_SSL", :boolean),
  ssl_opts: [verify: :verify_none],
  url: get_env("DATABASE_URL") || "postgres://localhost/accent_development",
  socket_options: if(ecto_ipv6?, do: [:inet6], else: [])

config :accent, Accent.MachineTranslations,
  default_providers_config: %{
    "google_translate" => %{"key" => get_env("GOOGLE_TRANSLATIONS_SERVICE_ACCOUNT_KEY")},
    "deepl" => %{"key" => get_env("DEEPL_TRANSLATIONS_KEY")}
  }

config :accent, LanguageTool, languages: get_env("LANGUAGE_TOOL_LANGUAGES", :comma_separated_list)

providers = []

providers =
  if get_env("GOOGLE_API_CLIENT_ID"),
    do: [{:google, {Ueberauth.Strategy.Google, [scope: "email openid"]}} | providers],
    else: providers

providers =
  if get_env("SLACK_CLIENT_ID"),
    do: [
      {:slack, {Ueberauth.Strategy.Slack, [default_user_scope: "users:read", team: get_env("SLACK_TEAM_ID")]}}
      | providers
    ],
    else: providers

providers =
  if get_env("GITHUB_CLIENT_ID"),
    do: [{:github, {Ueberauth.Strategy.Github, [default_scope: "user"]}} | providers],
    else: providers

providers =
  if get_env("GITLAB_CLIENT_ID"),
    do: [{:gitlab, {Ueberauth.Strategy.Gitlab, [default_scope: "read_user"]}} | providers],
    else: providers

providers =
  if get_env("DISCORD_CLIENT_ID"),
    do: [{:discord, {Ueberauth.Strategy.Discord, [default_scope: "identify email"]}} | providers],
    else: providers

providers =
  if get_env("MICROSOFT_CLIENT_ID"),
    do: [{:microsoft, {Ueberauth.Strategy.Microsoft, [prompt: "select_account"]}} | providers],
    else: providers

providers = if get_env("AUTH0_CLIENT_ID"), do: [{:auth0, {Ueberauth.Strategy.Auth0, []}} | providers], else: providers

providers =
  if get_env("DUMMY_LOGIN_ENABLED"),
    do: [{:dummy, {Accent.Auth.Ueberauth.DummyStrategy, []}} | providers],
    else: providers

config :ueberauth, Ueberauth, providers: providers

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: get_env("GOOGLE_API_CLIENT_ID"),
  client_secret: get_env("GOOGLE_API_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: get_env("GITHUB_CLIENT_ID"),
  client_secret: get_env("GITHUB_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Auth0.OAuth,
  domain: System.get_env("AUTH0_DOMAIN"),
  client_id: System.get_env("AUTH0_CLIENT_ID"),
  client_secret: System.get_env("AUTH0_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Gitlab.OAuth,
  client_id: get_env("GITLAB_CLIENT_ID"),
  client_secret: get_env("GITLAB_CLIENT_SECRET"),
  redirect_uri: "#{static_uri}/auth/gitlab/callback",
  site: get_env("GITLAB_SITE_URL") || "https://gitlab.com",
  authorize_url: "#{get_env("GITLAB_SITE_URL") || "https://gitlab.com"}/oauth/authorize",
  token_url: "#{get_env("GITLAB_SITE_URL") || "https://gitlab.com"}/oauth/token"

config :ueberauth, Ueberauth.Strategy.Slack.OAuth,
  client_id: get_env("SLACK_CLIENT_ID"),
  client_secret: get_env("SLACK_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Discord.OAuth,
  client_id: get_env("DISCORD_CLIENT_ID"),
  client_secret: get_env("DISCORD_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Microsoft.OAuth,
  client_id: get_env("MICROSOFT_CLIENT_ID"),
  client_secret: get_env("MICROSOFT_CLIENT_SECRET"),
  tenant_id: get_env("MICROSOFT_TENANT_ID")

config :accent, Accent.WebappView,
  path: "priv/static/webapp/index.html",
  sentry_dsn: get_env("WEBAPP_SENTRY_DSN") || "",
  skip_subresource_integrity: get_env("WEBAPP_SKIP_SUBRESOURCE_INTEGRITY", :boolean)

config :tesla, logger_enabled: true

config :new_relic_agent,
  app_name: get_env("NEW_RELIC_APP_NAME"),
  license_key: get_env("NEW_RELIC_LICENSE_KEY")

if get_env("SENTRY_DSN") do
  config :sentry,
    dsn: get_env("SENTRY_DSN"),
    environment_name: get_env("SENTRY_ENVIRONMENT_NAME"),
    included_environments: ~w(dev prod production),
    root_source_code_path: File.cwd!()
else
  config :sentry, included_environments: []
end

config :accent, Accent.Mailer,
  mailer_from: get_env("MAILER_FROM"),
  x_smtpapi_header: get_env("SMTP_API_HEADER")

cond do
  get_env("SENDGRID_API_KEY") ->
    config :accent, Accent.Mailer,
      adapter: Bamboo.SendGridAdapter,
      api_key: get_env("SENDGRID_API_KEY")

  get_env("MANDRILL_API_KEY") ->
    config :accent, Accent.Mailer,
      adapter: Bamboo.MandrillAdapter,
      api_key: get_env("MANDRILL_API_KEY")

  get_env("MAILGUN_API_KEY") ->
    config :accent, Accent.Mailer,
      adapter: Bamboo.MailgunAdapter,
      api_key: get_env("MAILGUN_API_KEY"),
      domain: get_env("MAILGUN_DOMAIN"),
      base_uri: get_env("MAILGUN_BASE_URI")

  get_env("SMTP_ADDRESS") ->
    config :accent, Accent.Mailer,
      adapter: Bamboo.SMTPAdapter,
      server: get_env("SMTP_ADDRESS"),
      port: get_env("SMTP_PORT"),
      username: get_env("SMTP_USERNAME"),
      password: get_env("SMTP_PASSWORD")

  config_env() == :test ->
    config :accent, Accent.Mailer,
      mailer_from: "accent-test@example.com",
      x_smtpapi_header: ~s({"category": ["test", "accent-api-test"]}),
      adapter: Bamboo.TestAdapter

  true ->
    config :accent, Accent.Mailer, adapter: Bamboo.LocalAdapter
end
