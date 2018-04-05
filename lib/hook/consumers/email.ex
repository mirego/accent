defmodule Accent.Hook.Consumers.Email do
  use Accent.Hook.EventConsumer, subscribe_to: [Accent.Hook.Producers.Email]

  alias Accent.{
    Repo,
    Mailer,
    ProjectInviteEmail,
    CreateCommentEmail,
    Hook
  }

  @supported_events ~w(create_collaborator create_comment)

  def handle_events(events, _from, state) do
    events
    |> Enum.filter(&filter_event/1)
    |> Enum.each(fn event ->
      event
      |> fetch_emails()
      |> build_email(event)
      |> Mailer.deliver_later()
    end)

    {:noreply, [], state}
  end

  defp filter_event(%Hook.Context{event: event}), do: event in @supported_events

  defp build_email(emails, %Hook.Context{event: "create_collaborator", project: project, user: user}) do
    ProjectInviteEmail.create(emails, user, project)
  end

  defp build_email(emails, %Hook.Context{event: "create_comment", payload: payload}) do
    CreateCommentEmail.create(emails, payload[:comment])
  end

  defp fetch_emails(%Hook.Context{event: "create_collaborator", payload: payload}) do
    [payload[:collaborator].email]
  end

  defp fetch_emails(%Hook.Context{event: "create_comment", payload: payload, user: context_user}) do
    payload[:comment]
    |> Map.get(:translation)
    |> Repo.preload(comments_subscriptions: :user)
    |> Map.get(:comments_subscriptions)
    |> Enum.map(& &1.user)
    |> Enum.filter(fn user -> user.id !== context_user.id end)
    |> Enum.map(& &1.email)
  end
end
