defmodule Accent.CreateCommentEmail do
  use Bamboo.Phoenix, view: Accent.EmailView

  import Accent.EmailViewConfigHelper, only: [mailer_from: 0, x_smtpapi_header: 0]

  @spec create(list(String.t()), Accent.Project.t(), map()) :: Bamboo.Email.t()
  def create(emails, project, comment) do
    base_email()
    |> to(emails)
    |> mailer_subject(project)
    |> assign(:email, comment["user"]["email"])
    |> assign(:key, comment["translation"]["key"])
    |> assign(:text, comment["text"])
    |> assign(:translation_path, translation_path(project, comment["translation"]["id"]))
    |> render(:create_comment)
  end

  defp mailer_subject(email, project) do
    email
    |> subject(~s(Accent – New comment on "#{project.name}"))
  end

  defp base_email do
    new_email()
    |> from({"Accent", mailer_from()})
    |> put_layout({Accent.EmailLayoutView, :index})
    |> add_x_smtpapi_header(x_smtpapi_header())
  end

  defp add_x_smtpapi_header(email, nil), do: email
  defp add_x_smtpapi_header(email, header), do: put_header(email, "X-SMTPAPI", header)

  defp translation_path(project, translation_id), do: "app/projects/#{project.id}/translations/#{translation_id}/conversation"
end
