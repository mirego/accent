defmodule Accent.EmailViewConfigHelper do
  def x_smtpapi_header, do: config()[:x_smtpapi_header]
  def mailer_from, do: config()[:mailer_from]
  def webapp_url, do: config()[:webapp_url]

  defp config do
    Application.get_env(:accent, Accent.Mailer)
  end
end
