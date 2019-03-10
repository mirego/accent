defmodule MockMailer do
  def deliver_later(%{to: []}), do: :ok

  def deliver_later(email) do
    send(self(), {:delivered_email, normalize_for_testing(email)})
  end

  def normalize_for_testing(email) do
    email
    |> Bamboo.Test.normalize_for_testing()
    |> Map.put(:to, [])
  end
end

defmodule AccentTest.Hook.Consumers.Email do
  use Accent.RepoCase

  alias Accent.{
    Collaborator,
    Comment,
    CreateCommentEmail,
    Hook.Consumers.Email,
    Language,
    Project,
    ProjectInviteEmail,
    Repo,
    Revision,
    Translation,
    TranslationCommentsSubscription,
    User
  }

  setup do
    language = %Language{name: "Test"} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "Test"} |> Repo.insert!()
    user = %User{fullname: "Test", email: "foo@test.com"} |> Repo.insert!()
    revision = %Revision{project_id: project.id, language_id: language.id, master: true} |> Repo.insert!()
    translation = %Translation{key: "foo", corrected_text: "bar", proposed_text: "bar", revision_id: revision.id} |> Repo.insert!()

    [project: project, translation: translation, user: user]
  end

  test "commenter subscribed", %{project: project, translation: translation, user: user} do
    %TranslationCommentsSubscription{translation_id: translation.id, user_id: user.id} |> Repo.insert!()
    comment = %Comment{translation_id: translation.id, user_id: user.id, text: "This is a comment"} |> Repo.insert!()
    comment = Repo.preload(comment, [:user, translation: [revision: :project]])

    event = %Accent.Hook.Context{project: project, user: user, event: "create_comment", payload: %{comment: comment}}

    {:noreply, _, _} = Email.handle_events([event], nil, {:mailer, MockMailer})

    email =
      ["comment@test.com"]
      |> CreateCommentEmail.create(comment)
      |> MockMailer.normalize_for_testing()

    refute_receive {:delivered_email, ^email}
  end

  test "comment", %{project: project, translation: translation, user: user} do
    %TranslationCommentsSubscription{translation_id: translation.id, user_id: user.id} |> Repo.insert!()
    commenter = %User{fullname: "Commenter", email: "comment@test.com"} |> Repo.insert!()
    comment = %Comment{translation_id: translation.id, user_id: commenter.id, text: "This is a comment"} |> Repo.insert!()
    comment = Repo.preload(comment, [:user, translation: [revision: :project]])

    event = %Accent.Hook.Context{project: project, user: commenter, event: "create_comment", payload: %{comment: comment}}

    {:noreply, _, _} = Email.handle_events([event], nil, {:mailer, MockMailer})

    email =
      ["foo@test.com"]
      |> CreateCommentEmail.create(comment)
      |> MockMailer.normalize_for_testing()

    assert_receive {:delivered_email, ^email}
  end

  test "collaborator", %{project: project, user: user} do
    collaborator = %Collaborator{email: "collab@test.com", project_id: project.id} |> Repo.insert!()
    event = %Accent.Hook.Context{project: project, user: user, event: "create_collaborator", payload: %{collaborator: collaborator}}

    {:noreply, _, _} = Email.handle_events([event], nil, {:mailer, MockMailer})

    email =
      ["collab@test.com"]
      |> ProjectInviteEmail.create(user, project)
      |> MockMailer.normalize_for_testing()

    assert_receive {:delivered_email, ^email}
  end

  test "unknown event", %{project: project, translation: translation, user: user} do
    %TranslationCommentsSubscription{translation_id: translation.id, user_id: user.id} |> Repo.insert!()
    commenter = %User{fullname: "Commenter", email: "comment@test.com"} |> Repo.insert!()
    comment = %Comment{translation_id: translation.id, user_id: commenter.id, text: "This is a comment"} |> Repo.insert!()
    comment = Repo.preload(comment, [:user, translation: [revision: :project]])

    event = %Accent.Hook.Context{project: project, user: user, event: "update_comment", payload: %{comment: comment}}

    {:noreply, _, _} = Email.handle_events([event], nil, {:mailer, MockMailer})

    email =
      ["foo@test.com"]
      |> CreateCommentEmail.create(comment)
      |> MockMailer.normalize_for_testing()

    refute_receive {:delivered_email, ^email}
  end
end
