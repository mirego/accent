defmodule Accent.EmailViewConfigHelper do
  @moduledoc false
  alias Accent.Router.Helpers, as: Routes

  def x_smtpapi_header, do: config()[:x_smtpapi_header]
  def mailer_from, do: config()[:mailer_from]

  def webapp_url do
    Routes.static_url(Accent.Endpoint, "/")
  end

  defp config do
    Application.get_env(:accent, Accent.Mailer)
  end
end
