defmodule AccentTest.Movement.Builders.TranslationUpdate do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Language
  alias Accent.ProjectCreator
  alias Accent.Repo
  alias Accent.Translation
  alias Accent.User
  alias Accent.Version
  alias Movement.Builders.TranslationUpdate, as: TranslationUpdateBuilder
  alias Movement.Context

  test "builder" do
    translation = %Translation{
      key: "a",
      proposed_text: "A",
      corrected_text: "A"
    }

    context =
      %Context{}
      |> Context.assign(:text, "Updated!")
      |> Context.assign(:translation, translation)
      |> TranslationUpdateBuilder.build()

    operations = Enum.map(context.operations, &Map.take(&1, [:key, :text, :action]))

    assert operations === [
             %{
               key: "a",
               text: "Updated!",
               action: "update"
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
      |> Context.assign(:text, "Updated!")
      |> Context.assign(:translation, translation)
      |> TranslationUpdateBuilder.build()

    operations = Enum.map(context.operations, &Map.take(&1, [:key, :text, :action, :translation_id]))

    assert operations === [
             %{
               translation_id: translation.id,
               key: "a",
               text: "Updated!",
               action: "update"
             },
             %{
               translation_id: source_translation.id,
               key: "a",
               text: "Updated!",
               action: "update"
             }
           ]
  end

  test "builder same text translated" do
    translation = %Translation{
      key: "a",
      proposed_text: "A",
      corrected_text: "A",
      translated: true
    }

    context =
      %Context{}
      |> Context.assign(:text, "A")
      |> Context.assign(:translation, translation)
      |> TranslationUpdateBuilder.build()

    assert context.operations == []
  end

  test "builder same text not translated" do
    translation = %Translation{
      key: "a",
      proposed_text: "A",
      corrected_text: "A",
      translated: false
    }

    context =
      %Context{}
      |> Context.assign(:text, "A")
      |> Context.assign(:translation, translation)
      |> TranslationUpdateBuilder.build()

    assert length(context.operations) === 1
  end

  test "builder value type null to nothing" do
    translation = %Translation{
      key: "a",
      proposed_text: "null",
      corrected_text: "null",
      value_type: "null",
      placeholders: []
    }

    context =
      %Context{}
      |> Context.assign(:text, "Hello!")
      |> Context.assign(:translation, translation)
      |> TranslationUpdateBuilder.build()

    operations = Enum.map(context.operations, &Map.take(&1, [:value_type]))

    assert operations === [%{value_type: "string"}]
  end

  test "builder value type empty to nothing" do
    translation = %Translation{
      key: "a",
      proposed_text: "",
      corrected_text: "",
      value_type: "empty",
      placeholders: []
    }

    context =
      %Context{}
      |> Context.assign(:text, "Hello!")
      |> Context.assign(:translation, translation)
      |> TranslationUpdateBuilder.build()

    operations = Enum.map(context.operations, &Map.take(&1, [:value_type]))

    assert operations === [%{value_type: "string"}]
  end

  test "builder value type nothing to empty" do
    translation = %Translation{
      key: "a",
      proposed_text: "hello!",
      corrected_text: "hello!",
      value_type: "",
      placeholders: []
    }

    context =
      %Context{}
      |> Context.assign(:text, "")
      |> Context.assign(:translation, translation)
      |> TranslationUpdateBuilder.build()

    operations = Enum.map(context.operations, &Map.take(&1, [:value_type]))

    assert operations === [%{value_type: "empty"}]
  end
end
