defmodule AccentTest.Hook.Outbounds.Email do
  @moduledoc false
  use Accent.RepoCase, async: true
  use Bamboo.Test

  alias Accent.Collaborator
  alias Accent.Comment
  alias Accent.CreateCommentEmail
  alias Accent.Hook.Context
  alias Accent.Hook.Outbounds.Email
  alias Accent.Language
  alias Accent.Project
  alias Accent.ProjectInviteEmail
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.TranslationCommentsSubscription
  alias Accent.User

  setup do
    language = Factory.insert(Language, name: "Test")
    project = Factory.insert(Project)
    user = Factory.insert(User, fullname: "Test", email: "foo@test.com")
    revision = Factory.insert(Revision, project_id: project.id, language_id: language.id, master: true)

    translation =
      Factory.insert(Translation, key: "foo", corrected_text: "bar", proposed_text: "bar", revision_id: revision.id)

    [project: project, translation: translation, user: user]
  end

  test "commenter subscribed", %{project: project, translation: translation, user: user} do
    Factory.insert(TranslationCommentsSubscription, translation_id: translation.id, user_id: user.id)
    comment = Factory.insert(Comment, translation_id: translation.id, user_id: user.id, text: "This is a comment")
    comment = Repo.preload(comment, [:user, translation: [revision: :project]])

    payload = %{
      "text" => comment.text,
      "translation" => %{"id" => translation.id, "key" => translation.key}
    }

    context =
      to_worker_args(%Context{
        project_id: project.id,
        user_id: user.id,
        event: "create_comment",
        payload: payload
      })

    _ = Email.perform(%Oban.Job{args: context})

    refute_delivered_email(CreateCommentEmail.create(["comment@test.com"], user, project, payload))
  end

  test "comment", %{project: project, translation: translation, user: user} do
    Factory.insert(TranslationCommentsSubscription, translation_id: translation.id, user_id: user.id)
    commenter = Factory.insert(User, fullname: "Commenter", email: "comment@test.com")
    comment = Factory.insert(Comment, translation_id: translation.id, user_id: commenter.id, text: "This is a comment")

    payload = %{
      "text" => comment.text,
      "translation" => %{"id" => translation.id, "key" => translation.key}
    }

    context =
      to_worker_args(%Context{
        project_id: project.id,
        user_id: commenter.id,
        event: "create_comment",
        payload: payload
      })

    _ = Email.perform(%Oban.Job{args: context})

    assert_delivered_email(CreateCommentEmail.create(["foo@test.com"], commenter, project, payload))
  end

  test "collaborator", %{project: project, user: user} do
    collaborator = Factory.insert(Collaborator, email: "collab@test.com", project_id: project.id)

    payload = %{
      "collaborator" => %{
        "email" => collaborator.email
      }
    }

    context =
      to_worker_args(%Context{
        project_id: project.id,
        user_id: user.id,
        event: "create_collaborator",
        payload: payload
      })

    _ = Email.perform(%Oban.Job{args: context})

    assert_delivered_email(ProjectInviteEmail.create(["collab@test.com"], user, project))
  end
end
