defmodule AccentTest.GraphQL.Resolvers.Translation do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Document
  alias Accent.GraphQL.Resolvers.Translation, as: Resolver
  alias Accent.Language
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User
  alias Accent.Version
  alias Ecto.UUID

  defmodule PlugConn do
    @moduledoc false
    defstruct [:assigns]
  end

  setup do
    user = Factory.insert(User)
    french_language = Factory.insert(Language)
    project = Factory.insert(Project)

    revision = Factory.insert(Revision, language_id: french_language.id, project_id: project.id, master: true)
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, [user: user, project: project, revision: revision, context: context]}
  end

  test "key", %{revision: revision, context: context} do
    {:ok, key} = Resolver.key(%Translation{revision_id: revision.id, key: "Foo", proposed_text: "bar"}, %{}, context)
    assert key === "Foo"

    {:ok, key} =
      Resolver.key(%Translation{revision_id: revision.id, key: "Foo.__KEY__1.Bar", proposed_text: "bar"}, %{}, context)

    assert key === "Foo.[1].Bar"
  end

  test "correct", %{revision: revision, context: context} do
    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: true,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar"
      )

    {:ok, result} = Resolver.correct(translation, %{text: "Corrected text"}, context)

    assert get_in(result, [:errors]) == nil
    assert get_in(result, [:translation, Access.key(:id)]) == translation.id
    assert get_in(Repo.all(Translation), [Access.all(), Access.key(:corrected_text)]) == ["Corrected text"]
    assert get_in(Repo.all(Translation), [Access.all(), Access.key(:conflicted)]) == [false]
  end

  test "uncorrect", %{revision: revision, context: context} do
    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: false,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar"
      )

    {:ok, result} = Resolver.uncorrect(translation, %{text: "baz"}, context)

    assert get_in(result, [:errors]) == nil
    assert get_in(result, [:translation, Access.key(:id)]) == translation.id
    assert get_in(Repo.all(Translation), [Access.all(), Access.key(:corrected_text)]) == ["baz"]
    assert get_in(Repo.all(Translation), [Access.all(), Access.key(:conflicted_text)]) == ["bar"]
    assert get_in(Repo.all(Translation), [Access.all(), Access.key(:conflicted)]) == [true]
  end

  test "update settings", %{revision: revision, context: context} do
    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: true,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar",
        value_type: "string",
        plural: false,
        locked: false,
        placeholders: [],
        file_index: 1,
        file_comment: "old comment"
      )

    {:ok, result} =
      Resolver.update_settings(
        translation,
        %{
          plural: true,
          locked: true,
          value_type: "boolean",
          placeholders: ["count"],
          file_index: 5,
          file_comment: "new comment"
        },
        context
      )

    assert get_in(result, [:errors]) == nil

    updated = Repo.get!(Translation, translation.id)
    assert updated.plural == true
    assert updated.locked == true
    assert updated.value_type == "boolean"
    assert updated.placeholders == ["count"]
    assert updated.file_index == 5
    assert updated.file_comment == "new comment"
  end

  test "update settings with source_translation_id", %{revision: revision, context: context} do
    source_translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        key: "source",
        corrected_text: "source text",
        proposed_text: "source text"
      )

    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar"
      )

    {:ok, result} = Resolver.update_settings(translation, %{source_translation_id: source_translation.id}, context)

    assert get_in(result, [:errors]) == nil

    updated = Repo.get!(Translation, translation.id)
    assert updated.source_translation_id == source_translation.id
  end

  test "update settings with empty args", %{revision: revision, context: context} do
    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar",
        value_type: "string",
        plural: false,
        locked: false
      )

    {:ok, result} = Resolver.update_settings(translation, %{}, context)

    assert get_in(result, [:errors]) == nil

    updated = Repo.get!(Translation, translation.id)
    assert updated.plural == false
    assert updated.locked == false
    assert updated.value_type == "string"
  end

  test "update settings with invalid source_translation_id", %{revision: revision, context: context} do
    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar"
      )

    {:ok, result} = Resolver.update_settings(translation, %{source_translation_id: UUID.generate()}, context)

    assert get_in(result, [:errors]) == ["unprocessable_entity"]
    assert get_in(result, [:translation]) == nil
  end

  test "update settings partial update", %{revision: revision, context: context} do
    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar",
        value_type: "string",
        plural: false,
        locked: false
      )

    {:ok, result} = Resolver.update_settings(translation, %{locked: true}, context)

    assert get_in(result, [:errors]) == nil

    updated = Repo.get!(Translation, translation.id)
    assert updated.locked == true
    assert updated.plural == false
    assert updated.value_type == "string"
  end

  test "update", %{revision: revision, context: context} do
    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: true,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar"
      )

    {:ok, result} = Resolver.update(translation, %{text: "Updated text"}, context)

    assert get_in(result, [:errors]) == nil
    assert get_in(result, [:translation, Access.key(:id)]) == translation.id
    assert get_in(Repo.all(Translation), [Access.all(), Access.key(:corrected_text)]) == ["Updated text"]
    assert get_in(Repo.all(Translation), [Access.all(), Access.key(:conflicted)]) == [true]
  end

  test "show project", %{project: project, revision: revision, context: context} do
    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: true,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar"
      )

    {:ok, result} = Resolver.show_project(project, %{id: translation.id}, context)

    assert get_in(result, [Access.key(:id)]) == translation.id
  end

  test "show project unknown id", %{project: project, context: context} do
    {:ok, result} = Resolver.show_project(project, %{id: UUID.generate()}, context)

    assert is_nil(result)
  end

  test "show project unknown project", %{revision: revision, context: context} do
    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: true,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar"
      )

    {:ok, result} = Resolver.show_project(%Project{id: UUID.generate()}, %{id: translation.id}, context)

    assert is_nil(result)
  end

  test "list revision", %{revision: revision, context: context} do
    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: true,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar"
      )

    Factory.insert(Translation,
      revision_id: revision.id,
      conflicted: true,
      key: "hidden",
      corrected_text: "bar",
      proposed_text: "bar",
      locked: true
    )

    {:ok, result} = Resolver.list_revision(revision, %{}, context)

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [translation.id]
  end

  test "list revision with query", %{revision: revision, context: context} do
    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: true,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar"
      )

    Factory.insert(Translation,
      revision_id: revision.id,
      conflicted: true,
      key: "aux",
      corrected_text: "foo",
      proposed_text: "foo"
    )

    {:ok, result} = Resolver.list_revision(revision, %{query: "bar"}, context)

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [translation.id]
  end

  test "list revision with document", %{project: project, revision: revision, context: context} do
    document = Factory.insert(Document, path: "bar", format: "json", project_id: project.id)
    other_document = Factory.insert(Document, path: "foo", format: "json", project_id: project.id)

    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: true,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar",
        document_id: document.id
      )

    Factory.insert(Translation,
      revision_id: revision.id,
      conflicted: true,
      key: "ok",
      corrected_text: "foo",
      proposed_text: "foo",
      document_id: other_document.id
    )

    {:ok, result} = Resolver.list_revision(revision, %{document: document.id}, context)

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [translation.id]
  end

  test "list revision with order", %{revision: revision, context: context} do
    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: true,
        key: "aaaaaa",
        corrected_text: "bar",
        proposed_text: "bar"
      )

    other_translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: true,
        key: "bbbbb",
        corrected_text: "foo",
        proposed_text: "foo"
      )

    {:ok, result} = Resolver.list_revision(revision, %{order: "-key"}, context)

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [other_translation.id, translation.id]
  end

  test "list revision with conflicted", %{revision: revision, context: context} do
    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: false,
        key: "bar",
        corrected_text: "bar",
        proposed_text: "bar"
      )

    Factory.insert(Translation,
      revision_id: revision.id,
      conflicted: true,
      key: "foo",
      corrected_text: "foo",
      proposed_text: "foo"
    )

    {:ok, result} = Resolver.list_revision(revision, %{is_conflicted: false}, context)

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [translation.id]
  end

  test "list revision with version", %{project: project, revision: revision, user: user, context: context} do
    version = Factory.insert(Version, name: "bar", tag: "v1.0", project_id: project.id, user_id: user.id)
    other_version = Factory.insert(Version, name: "foo", tag: "v2.0", project_id: project.id, user_id: user.id)

    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: true,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar",
        version_id: version.id
      )

    Factory.insert(Translation,
      revision_id: revision.id,
      conflicted: true,
      key: "ok",
      corrected_text: "foo",
      proposed_text: "foo",
      version_id: other_version.id
    )

    {:ok, result} = Resolver.list_revision(revision, %{version: version.id}, context)

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [translation.id]
  end

  test "related translations", %{project: project, revision: revision, context: context} do
    english_language = Factory.insert(Language, name: "english")

    other_revision =
      Factory.insert(Revision,
        language_id: english_language.id,
        project_id: project.id,
        master: false,
        master_revision_id: revision.id
      )

    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: true,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar"
      )

    other_translation =
      Factory.insert(Translation,
        revision_id: other_revision.id,
        conflicted: true,
        key: "ok",
        corrected_text: "foo",
        proposed_text: "foo"
      )

    {:ok, result} = Resolver.related_translations(translation, %{}, context)

    assert get_in(result, [Access.all(), Access.key(:id)]) == [other_translation.id]
  end

  test "master translation", %{project: project, revision: revision, context: context} do
    english_language = Factory.insert(Language, name: "english")

    other_revision =
      Factory.insert(Revision,
        language_id: english_language.id,
        project_id: project.id,
        master: false,
        master_revision_id: revision.id
      )

    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: true,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar"
      )

    other_translation =
      Factory.insert(Translation,
        revision_id: other_revision.id,
        conflicted: true,
        key: "ok",
        corrected_text: "foo",
        proposed_text: "foo"
      )

    {:ok, result} = Resolver.master_translation(other_translation, %{}, context)

    assert result.id == translation.id
  end

  test "master translation as master", %{project: project, revision: revision, context: context} do
    english_language = Factory.insert(Language, name: "english")

    other_revision =
      Factory.insert(Revision,
        language_id: english_language.id,
        project_id: project.id,
        master: false,
        master_revision_id: revision.id
      )

    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: true,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar"
      )

    Factory.insert(Translation,
      revision_id: other_revision.id,
      conflicted: true,
      key: "ok",
      corrected_text: "foo",
      proposed_text: "foo"
    )

    {:ok, result} = Resolver.master_translation(translation, %{}, context)

    assert result.id == translation.id
  end
end
