use Mix.Config

if System.get_env("SMTP_ADDRESS") do
  config :accent, Accent.Mailer,
    webapp_host: System.get_env("WEBAPP_EMAIL_HOST"),
    mailer_from: System.get_env("MAILER_FROM"),
    adapter: Bamboo.SMTPAdapter,
    server: System.get_env("SMTP_ADDRESS"),
    port: System.get_env("SMTP_PORT"),
    username: System.get_env("SMTP_USERNAME"),
    password: System.get_env("SMTP_PASSWORD"),
    x_smtpapi_header: System.get_env("SMTP_API_HEADER")
else
  config :accent, Accent.Mailer,
    webapp_host: System.get_env("WEBAPP_EMAIL_HOST"),
    mailer_from: System.get_env("MAILER_FROM"),
    adapter: Bamboo.LocalAdapter
end
