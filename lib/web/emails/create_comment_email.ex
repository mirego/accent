defmodule Accent.CreateCommentEmail do
  @moduledoc false
  use Bamboo.Phoenix, view: Accent.EmailView

  @spec create(list(String.t()), Accent.User.t(), Accent.Project.t(), map()) :: Bamboo.Email.t()
  def create(emails, user, project, comment) do
    Accent.BaseEmail.new()
    |> to(emails)
    |> mailer_subject(project)
    |> assign(:user, user)
    |> assign(:key, comment["translation"]["key"])
    |> assign(:text, comment["text"])
    |> assign(:translation_path, translation_path(project, comment["translation"]["id"]))
    |> render(:create_comment)
  end

  defp mailer_subject(email, project) do
    subject(email, ~s(Accent – New comment on "#{project.name}"))
  end

  defp translation_path(project, translation_id),
    do: "app/projects/#{project.id}/translations/#{translation_id}/conversation"
end
