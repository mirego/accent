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

  describe "list grouped project" do
    setup %{project: project, revision: revision} do
      english_language = Factory.insert(Language, name: "english")
      spanish_language = Factory.insert(Language, name: "spanish")
      document = Factory.insert(Document, project_id: project.id, path: "a")

      other_revision =
        Factory.insert(Revision,
          language_id: english_language.id,
          project_id: project.id,
          master: false,
          master_revision_id: revision.id
        )

      third_revision =
        Factory.insert(Revision,
          language_id: spanish_language.id,
          project_id: project.id,
          master: false,
          master_revision_id: revision.id
        )

      insert = fn revision, key, conflicted ->
        Factory.insert(Translation,
          revision_id: revision.id,
          document_id: document.id,
          key: key,
          conflicted: conflicted,
          corrected_text: key,
          proposed_text: key
        )
      end

      a_master = insert.(revision, "a", false)
      a_other = insert.(other_revision, "a", true)
      b_master = insert.(revision, "b", false)
      b_other = insert.(other_revision, "b", false)
      c_third = insert.(third_revision, "c", true)

      other_project = Factory.insert(Project)

      other_project_revision =
        Factory.insert(Revision, language_id: english_language.id, project_id: other_project.id, master: true)

      Factory.insert(Translation, revision_id: other_project_revision.id, key: "a", conflicted: true)

      {:ok,
       [
         document: document,
         other_revision: other_revision,
         third_revision: third_revision,
         a_master: a_master,
         a_other: a_other,
         b_master: b_master,
         b_other: b_other,
         c_third: c_third
       ]}
    end

    test "default related revisions", %{project: project, revision: revision, other_revision: other_revision} = ctx do
      {:ok, result} = Resolver.list_grouped_project(project, %{related_revisions: []}, ctx.context)

      assert result.meta.total_entries == 3
      assert Enum.map(result.revisions, & &1.id) == [revision.id, other_revision.id]
      assert Enum.map(result.entries, & &1.key) == ["a", "b", "c"]
      assert Enum.map(result.entries, & &1.document_id) == [ctx.document.id, ctx.document.id, ctx.document.id]

      assert Enum.map(result.entries, &translation_ids/1) == [
               Enum.sort([ctx.a_master.id, ctx.a_other.id]),
               Enum.sort([ctx.b_master.id, ctx.b_other.id]),
               [nil]
             ]

      assert Enum.all?(result.entries, &(&1.revision_ids == [revision.id, other_revision.id]))
    end

    test "missing related revisions", %{project: project, revision: revision, other_revision: other_revision} = ctx do
      {:ok, result} = Resolver.list_grouped_project(project, %{}, ctx.context)

      assert result.meta.total_entries == 3
      assert Enum.map(result.revisions, & &1.id) == [revision.id, other_revision.id]
    end

    test "conflicted", %{project: project} = ctx do
      {:ok, result} = Resolver.list_grouped_project(project, %{related_revisions: [], is_conflicted: true}, ctx.context)

      assert result.meta.total_entries == 2
      assert Enum.map(result.entries, & &1.key) == ["a", "c"]
    end

    test "explicit related revisions", %{project: project, revision: revision, third_revision: third_revision} = ctx do
      {:ok, result} =
        Resolver.list_grouped_project(
          project,
          %{related_revisions: [third_revision.id, revision.id]},
          ctx.context
        )

      assert result.meta.total_entries == 3
      assert Enum.map(result.revisions, & &1.id) == [third_revision.id, revision.id]

      assert Enum.map(result.entries, &translation_ids/1) == [
               [ctx.a_master.id],
               [ctx.b_master.id],
               [ctx.c_third.id]
             ]
    end

    test "pagination", %{project: project} = ctx do
      {:ok, result} =
        Resolver.list_grouped_project(project, %{related_revisions: [], page: 2, page_size: 2}, ctx.context)

      assert result.meta.total_entries == 3
      assert result.meta.total_pages == 2
      assert Enum.map(result.entries, & &1.key) == ["c"]
    end

    test "graphql translations batch", %{project: project, user: user} = ctx do
      user = %{user | permissions: %{project.id => "owner"}}

      {:ok, %{data: data}} =
        Absinthe.run(
          """
          query($projectId: ID!) {
            viewer {
              project(id: $projectId) {
                groupedTranslations(relatedRevisions: []) {
                  meta { totalEntries }
                  revisions { id }
                  entries { key document { id } translations { id revision { id } } }
                }
              }
            }
          }
          """,
          Accent.GraphQL.Schema,
          variables: %{"projectId" => project.id},
          context: %{conn: %Plug.Conn{assigns: %{current_user: user}}}
        )

      grouped = data["viewer"]["project"]["groupedTranslations"]
      [a, b, c] = grouped["entries"]

      assert grouped["meta"]["totalEntries"] == 3
      assert Enum.map(a["translations"], & &1["id"]) == [ctx.a_master.id, ctx.a_other.id]
      assert Enum.map(b["translations"], & &1["id"]) == [ctx.b_master.id, ctx.b_other.id]
      assert c["translations"] == []
      assert a["document"]["id"] == ctx.document.id
    end
  end

  defp translation_ids(entry) do
    entry.translation_ids
    |> Enum.map(fn
      nil -> nil
      id -> UUID.cast!(id)
    end)
    |> Enum.sort()
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
