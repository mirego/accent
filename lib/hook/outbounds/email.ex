defmodule Accent.Hook.Outbounds.Email do
  @moduledoc false
  use Oban.Worker, queue: :hook

  alias Accent.CreateCommentEmail
  alias Accent.ProjectInviteEmail
  alias Accent.Repo
  alias Accent.Translation

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    context = Accent.Hook.Context.from_worker(args)

    email =
      context
      |> fetch_emails()
      |> build_email(context)
      |> Accent.Mailer.deliver_later()

    {:ok, email}
  end

  defp build_email(emails, %{event: "create_collaborator", project: project, user: user}) do
    ProjectInviteEmail.create(emails, user, project)
  end

  defp build_email(emails, %{event: "create_comment", project: project, user: user, payload: payload}) do
    CreateCommentEmail.create(emails, user, project, payload)
  end

  defp fetch_emails(%{event: "create_collaborator", payload: payload}) do
    [get_in(payload, ~w(collaborator email))]
  end

  defp fetch_emails(%{event: "create_comment", payload: payload, user: context_user}) do
    translation_id = get_in(payload, ~w(translation id))

    Translation
    |> Repo.get(translation_id)
    |> Repo.preload(comments_subscriptions: :user)
    |> Map.get(:comments_subscriptions)
    |> Enum.filter(&(&1.user.id !== context_user.id))
    |> Enum.map(& &1.user.email)
  end
end
