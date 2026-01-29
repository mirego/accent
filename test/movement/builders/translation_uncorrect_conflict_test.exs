defmodule AccentTest.Movement.Builders.TranslationUncorrectConflict do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Language
  alias Accent.ProjectCreator
  alias Accent.Repo
  alias Accent.Translation
  alias Accent.User
  alias Accent.Version
  alias Movement.Builders.TranslationUncorrectConflict, as: TranslationUncorrectConflictBuilder
  alias Movement.Context

  test "builder" do
    translation = %Translation{
      key: "a",
      proposed_text: "A"
    }

    context =
      %Context{}
      |> Context.assign(:translation, translation)
      |> Context.assign(:text, "B")
      |> TranslationUncorrectConflictBuilder.build()

    operations = Enum.map(context.operations, &Map.take(&1, [:key, :action, :text]))

    assert operations === [
             %{
               key: "a",
               text: "B",
               action: "uncorrect_conflict"
             }
           ]
  end

  test "builder copy on latest version" do
    user = Factory.insert(User, email: "test@test.com")
    language = Factory.insert(Language)

    {:ok, project} =
      ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)

    revision = Repo.one!(Ecto.assoc(project, :revisions))

    version =
      Factory.insert(Version,
        name: "1",
        tag: "v1",
        project_id: project.id,
        user_id: user.id,
        copy_on_update_translation: true
      )

    source_translation =
      Factory.insert(Translation,
        key: "a",
        proposed_text: "A",
        corrected_text: "A",
        revision_id: revision.id,
        version_id: nil
      )

    translation =
      Factory.insert(Translation,
        key: "a",
        proposed_text: "A",
        corrected_text: "A",
        version_id: version.id,
        revision_id: revision.id,
        source_translation_id: source_translation.id
      )

    context =
      %Context{}
      |> Context.assign(:text, "Uncorrected!")
      |> Context.assign(:translation, translation)
      |> TranslationUncorrectConflictBuilder.build()

    operations = Enum.map(context.operations, &Map.take(&1, [:key, :text, :action, :translation_id]))

    assert operations === [
             %{
               translation_id: translation.id,
               key: "a",
               text: "Uncorrected!",
               action: "uncorrect_conflict"
             },
             %{
               translation_id: source_translation.id,
               key: "a",
               text: "Uncorrected!",
               action: "uncorrect_conflict"
             }
           ]
  end

  test "builder without copy on latest version when disabled" do
    user = Factory.insert(User, email: "test2@test.com")
    language = Factory.insert(Language)

    {:ok, project} =
      ProjectCreator.create(params: %{main_color: "#f00", name: "My project 2", language_id: language.id}, user: user)

    revision = Repo.one!(Ecto.assoc(project, :revisions))

    version =
      Factory.insert(Version,
        name: "1",
        tag: "v1",
        project_id: project.id,
        user_id: user.id,
        copy_on_update_translation: false
      )

    source_translation =
      Factory.insert(Translation,
        key: "a",
        proposed_text: "A",
        corrected_text: "A",
        revision_id: revision.id,
        version_id: nil
      )

    translation =
      Factory.insert(Translation,
        key: "a",
        proposed_text: "A",
        corrected_text: "A",
        version_id: version.id,
        revision_id: revision.id,
        source_translation_id: source_translation.id
      )

    context =
      %Context{}
      |> Context.assign(:text, "Uncorrected!")
      |> Context.assign(:translation, translation)
      |> TranslationUncorrectConflictBuilder.build()

    operations = Enum.map(context.operations, &Map.take(&1, [:key, :text, :action, :translation_id]))

    assert operations === [
             %{
               translation_id: translation.id,
               key: "a",
               text: "Uncorrected!",
               action: "uncorrect_conflict"
             }
           ]
  end
end
