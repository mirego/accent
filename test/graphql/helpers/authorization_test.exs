defmodule AccentTest.GraphQL.Helpers.Authorization do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Collaborator
  alias Accent.Document
  alias Accent.GraphQL.Helpers.Authorization
  alias Accent.Integration
  alias Accent.Language
  alias Accent.Operation
  alias Accent.ProjectCreator
  alias Accent.Repo
  alias Accent.Translation
  alias Accent.TranslationCommentsSubscription
  alias Accent.User
  alias Accent.Version

  setup do
    user = Factory.insert(User)
    language = Factory.insert(Language)

    {:ok, project} =
      ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)

    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    document = Factory.insert(Document, project_id: project.id, path: "test", format: "json")
    version = Factory.insert(Version, project_id: project.id, name: "test", tag: "v1.0", user_id: user.id)
    translation = Factory.insert(Translation, revision_id: revision.id, key: "test", corrected_text: "bar")
    collaborator = Factory.insert(Collaborator, project_id: project.id, user_id: user.id, role: "owner")

    integration =
      Repo.insert!(%Integration{
        project_id: project.id,
        user_id: user.id,
        service: "slack",
        data: %{url: "http://example.com"}
      })

    translation_comments_subscription =
      Factory.insert(TranslationCommentsSubscription, translation_id: translation.id, user_id: user.id)

    {:ok,
     [
       project: project,
       document: document,
       revision: revision,
       user: user,
       version: version,
       translation: translation,
       collaborator: collaborator,
       integration: integration,
       translation_comments_subscription: translation_comments_subscription
     ]}
  end

  test "authorized viewer", %{user: user} do
    root = %{user: user}
    args = %{}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.viewer_authorize(:index_permissions, resolver).(root, args, context)

    assert_receive :ok
  end

  test "authorized viewer to create project", %{user: user} do
    root = %{user: user}
    args = %{}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.viewer_authorize(:create_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "unauthorized viewer" do
    root = %{user: nil}
    args = %{}
    context = %{conn: %{}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    result = Authorization.viewer_authorize(:index_permissions, resolver).(root, args, context)

    assert result == {:ok, nil}
    refute_receive :ok
  end

  test "authorized project root", %{user: user, project: project} do
    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = project
    args = %{}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.project_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "authorized project args", %{user: user, project: project} do
    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = nil
    args = %{id: project.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.project_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "unauthorized project role", %{user: user, project: project} do
    user = Map.put(user, :permissions, %{project.id => "reviewer"})
    root = project
    args = %{}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    result = Authorization.project_authorize(:create_slave, resolver).(root, args, context)

    assert result == {:ok, nil}
    refute_receive :ok
  end

  test "unauthorized project root", %{project: project} do
    user = Factory.insert(User, email: "test+2@test.com")
    user = Map.put(user, :permissions, %{})
    root = project
    args = %{}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    result = Authorization.project_authorize(:show_project, resolver).(root, args, context)

    assert result == {:ok, nil}
    refute_receive :ok
  end

  test "authorized revision root", %{user: user, revision: revision, project: project} do
    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = revision
    args = %{}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.revision_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "authorized revision args", %{user: user, revision: revision, project: project} do
    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = nil
    args = %{id: revision.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.revision_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "unauthorized revision role", %{user: user, revision: revision, project: project} do
    user = Map.put(user, :permissions, %{project.id => "reviewer"})
    root = revision
    args = %{}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    result = Authorization.revision_authorize(:create_slave, resolver).(root, args, context)

    assert result == {:ok, nil}
    refute_receive :ok
  end

  test "unauthorized revision root", %{revision: revision} do
    user = Factory.insert(User, email: "test+2@test.com")
    user = Map.put(user, :permissions, %{})
    root = revision
    args = %{}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    result = Authorization.revision_authorize(:show_project, resolver).(root, args, context)

    assert result == {:ok, nil}
    refute_receive :ok
  end

  test "authorized version root", %{user: user, version: version, project: project} do
    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = version
    args = %{}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.version_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "authorized version args", %{user: user, version: version, project: project} do
    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = nil
    args = %{id: version.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.version_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "unauthorized version role", %{user: user, version: version, project: project} do
    user = Map.put(user, :permissions, %{project.id => "reviewer"})
    root = version
    args = %{}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    result = Authorization.version_authorize(:create_slave, resolver).(root, args, context)

    assert result == {:ok, nil}
    refute_receive :ok
  end

  test "unauthorized version root", %{version: version} do
    user = Factory.insert(User, email: "test+2@test.com")
    user = Map.put(user, :permissions, %{})
    root = version
    args = %{}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    result = Authorization.version_authorize(:show_project, resolver).(root, args, context)

    assert result == {:ok, nil}
    refute_receive :ok
  end

  test "authorized translation root", %{user: user, translation: translation, project: project} do
    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = translation
    args = %{}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.translation_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "authorized translation revision preloaded root", %{
    user: user,
    revision: revision,
    translation: translation,
    project: project
  } do
    translation = %{translation | revision: revision}
    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = translation
    args = %{}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.translation_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "authorized translation args", %{user: user, translation: translation, project: project} do
    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = nil
    args = %{id: translation.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.translation_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "unauthorized translation role", %{user: user, translation: translation, project: project} do
    user = Map.put(user, :permissions, %{project.id => "reviewer"})
    root = translation
    args = %{}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    result = Authorization.translation_authorize(:create_slave, resolver).(root, args, context)

    assert result == {:ok, nil}
    refute_receive :ok
  end

  test "unauthorized translation root", %{translation: translation} do
    user = Factory.insert(User, email: "test+2@test.com")
    user = Map.put(user, :permissions, %{})
    root = translation
    args = %{}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    result = Authorization.translation_authorize(:show_project, resolver).(root, args, context)

    assert result == {:ok, nil}
    refute_receive :ok
  end

  test "authorized document args", %{user: user, document: document, project: project} do
    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = nil
    args = %{id: document.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.document_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "unauthorized document role", %{user: user, document: document, project: project} do
    user = Map.put(user, :permissions, %{project.id => "reviewer"})
    root = nil
    args = %{id: document.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    result = Authorization.document_authorize(:create_slave, resolver).(root, args, context)

    assert result == {:ok, nil}
    refute_receive :ok
  end

  test "authorized collaborator args", %{user: user, collaborator: collaborator, project: project} do
    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = nil
    args = %{id: collaborator.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.collaborator_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "unauthorized collaborator role", %{user: user, collaborator: collaborator, project: project} do
    user = Map.put(user, :permissions, %{project.id => "reviewer"})
    root = nil
    args = %{id: collaborator.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    result = Authorization.collaborator_authorize(:create_slave, resolver).(root, args, context)

    assert result == {:ok, nil}
    refute_receive :ok
  end

  test "authorized integration args", %{user: user, integration: integration, project: project} do
    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = nil
    args = %{id: integration.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.integration_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "unauthorized integration role", %{user: user, integration: integration, project: project} do
    user = Map.put(user, :permissions, %{project.id => "reviewer"})
    root = nil
    args = %{id: integration.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    result = Authorization.integration_authorize(:create_slave, resolver).(root, args, context)

    assert result == {:ok, nil}
    refute_receive :ok
  end

  test "authorized operation revision args", %{user: user, revision: revision, project: project} do
    operation = Factory.insert(Operation, revision_id: revision.id, user_id: user.id, key: "test", text: "bar")

    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = nil
    args = %{id: operation.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.operation_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "authorized operation translation args", %{user: user, translation: translation, project: project} do
    operation = Factory.insert(Operation, translation_id: translation.id, user_id: user.id, key: "test", text: "bar")

    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = nil
    args = %{id: operation.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.operation_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "authorized operation project args", %{user: user, project: project} do
    operation = Factory.insert(Operation, project_id: project.id, user_id: user.id, key: "test", text: "bar")

    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = nil
    args = %{id: operation.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.operation_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "unauthorized operation role", %{user: user, revision: revision, project: project} do
    operation = Factory.insert(Operation, revision_id: revision.id, user_id: user.id, key: "test", text: "bar")

    user = Map.put(user, :permissions, %{project.id => "reviewer"})
    root = nil
    args = %{id: operation.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    result = Authorization.operation_authorize(:create_slave, resolver).(root, args, context)

    assert result == {:ok, nil}
    refute_receive :ok
  end

  test "authorized translation_comments_subscription args", %{
    user: user,
    translation_comments_subscription: translation_comments_subscription,
    project: project
  } do
    user = Map.put(user, :permissions, %{project.id => "owner"})
    root = nil
    args = %{id: translation_comments_subscription.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    Authorization.translation_comment_subscription_authorize(:show_project, resolver).(root, args, context)

    assert_receive :ok
  end

  test "unauthorized translation_comments_subscription role", %{
    user: user,
    translation_comments_subscription: translation_comments_subscription,
    project: project
  } do
    user = Map.put(user, :permissions, %{project.id => "reviewer"})
    root = nil
    args = %{id: translation_comments_subscription.id}
    context = %{context: %{conn: %{assigns: %{current_user: user}}}}
    resolver = fn _, _, _ -> send(self(), :ok) end

    result = Authorization.translation_comment_subscription_authorize(:create_slave, resolver).(root, args, context)

    assert result == {:ok, nil}
    refute_receive :ok
  end
end
