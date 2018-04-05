defmodule Accent.EmailViewConfigHelper do
  def x_smtpapi_header, do: config()[:x_smtpapi_header]
  def mailer_from, do: config()[:mailer_from]
  def webapp_host, do: config()[:webapp_host]

  defp config do
    Application.get_env(:accent, Accent.Mailer)
  end
end
