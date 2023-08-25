defmodule Accent.ProjectInviteEmail do
  @moduledoc false
  use Bamboo.Phoenix, view: Accent.EmailView

  import Accent.EmailViewConfigHelper, only: [mailer_from: 0, x_smtpapi_header: 0]

  @spec create(String.t() | [String.t()], Accent.User.t(), Accent.Project.t()) :: Bamboo.Email.t()
  def create(email_address, user, project) do
    base_email()
    |> to(email_address)
    |> mailer_subject(project)
    |> assign(:email, email_address)
    |> assign(:project, project)
    |> assign(:user, user)
    |> render(:project_invite)
  end

  defp mailer_subject(email, project) do
    subject(email, ~s(Accent – Invitation to collaborate on "#{project.name}"))
  end

  defp base_email do
    new_email()
    |> from({"Accent", mailer_from()})
    |> put_layout({Accent.EmailLayoutView, :index})
    |> add_x_smtpapi_header(x_smtpapi_header())
  end

  defp add_x_smtpapi_header(email, nil), do: email
  defp add_x_smtpapi_header(email, header), do: put_header(email, "X-SMTPAPI", header)
end
