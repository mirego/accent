defmodule Accent.ProjectInviteEmail do
  @moduledoc false
  use Bamboo.Phoenix, view: Accent.EmailView

  @spec create(String.t() | [String.t()], Accent.User.t(), Accent.Project.t()) :: Bamboo.Email.t()
  def create(email_address, user, project) do
    Accent.BaseEmail.new()
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
end
