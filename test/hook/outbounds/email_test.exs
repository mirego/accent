defmodule AccentTest.Hook.Outbounds.Email do
  use Accent.RepoCase
  use Bamboo.Test

  alias Accent.{
    Collaborator,
    Comment,
    CreateCommentEmail,
    Hook.Outbounds.Email,
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

    payload = %{
      "text" => comment.text,
      "user" => %{"email" => user.email},
      "translation" => %{"id" => translation.id, "key" => translation.key}
    }

    context = to_worker_args(%Accent.Hook.Context{project_id: project.id, user_id: user.id, event: "create_comment", payload: payload})

    _ = Email.perform(context, %{})

    refute_delivered_email(CreateCommentEmail.create(["comment@test.com"], project, payload))
  end

  test "comment", %{project: project, translation: translation, user: user} do
    %TranslationCommentsSubscription{translation_id: translation.id, user_id: user.id} |> Repo.insert!()
    commenter = %User{fullname: "Commenter", email: "comment@test.com"} |> Repo.insert!()
    comment = %Comment{translation_id: translation.id, user_id: commenter.id, text: "This is a comment"} |> Repo.insert!()

    payload = %{
      "text" => comment.text,
      "user" => %{"email" => commenter.email},
      "translation" => %{"id" => translation.id, "key" => translation.key}
    }

    context = to_worker_args(%Accent.Hook.Context{project_id: project.id, user_id: commenter.id, event: "create_comment", payload: payload})

    _ = Email.perform(context, %{})

    assert_delivered_email(CreateCommentEmail.create(["foo@test.com"], project, payload))
  end

  test "collaborator", %{project: project, user: user} do
    collaborator = %Collaborator{email: "collab@test.com", project_id: project.id} |> Repo.insert!()

    payload = %{
      "collaborator" => %{
        "email" => collaborator.email
      }
    }

    context = to_worker_args(%Accent.Hook.Context{project_id: project.id, user_id: user.id, event: "create_collaborator", payload: payload})

    _ = Email.perform(context, %{})

    assert_delivered_email(ProjectInviteEmail.create(["collab@test.com"], user, project))
  end
end
