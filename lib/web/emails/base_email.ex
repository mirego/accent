defmodule Accent.BaseEmail do
  @moduledoc false
  import Accent.EmailViewConfigHelper, only: [mailer_from: 0, x_smtpapi_header: 0]
  import Bamboo.Email
  import Bamboo.Phoenix, only: [put_layout: 2]

  @spec new :: Bamboo.Email.t()
  def new do
    new_email()
    |> from({"Accent", mailer_from()})
    |> put_layout({Accent.EmailLayoutView, :index})
    |> put_x_smtpapi_header(x_smtpapi_header())
  end

  defp put_x_smtpapi_header(email, nil), do: email
  defp put_x_smtpapi_header(email, header), do: put_header(email, "X-SMTPAPI", header)
end
