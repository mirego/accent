use Mix.Config

if "${SMTP_ADDRESS}" do
  config :accent, Accent.Mailer,
    webapp_host: "${WEBAPP_EMAIL_HOST}",
    mailer_from: "${MAILER_FROM}",
    adapter: Bamboo.SMTPAdapter,
    server: "${SMTP_ADDRESS}",
    port: "${SMTP_PORT}",
    username: "${SMTP_USERNAME}",
    password: "${SMTP_PASSWORD}",
    x_smtpapi_header: "${SMTP_API_HEADER}"
else
  config :accent, Accent.Mailer,
    webapp_host: "${WEBAPP_EMAIL_HOST}",
    mailer_from: "${MAILER_FROM}",
    adapter: Bamboo.LocalAdapter
end
