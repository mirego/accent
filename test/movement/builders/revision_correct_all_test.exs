defmodule AccentTest.Movement.Builders.RevisionCorrectAll do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Language
  alias Accent.ProjectCreator
  alias Accent.Repo
  alias Accent.Translation
  alias Accent.User
  alias Accent.Version
  alias Movement.Builders.RevisionCorrectAll, as: RevisionCorrectAllBuilder
  alias Movement.Context

  setup do
    user = Factory.insert(User)
    language = Factory.insert(Language)

    {:ok, project} =
      ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)

    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()

    {:ok, [revision: revision, project: project]}
  end

  test "builder fetch translations and correct conflict", %{revision: revision} do
    translation = Factory.insert(Translation, key: "a", proposed_text: "A", conflicted: true, revision_id: revision.id)

    context =
      %Context{}
      |> Context.assign(:revision, revision)
      |> RevisionCorrectAllBuilder.build()

    translation_ids = Enum.map(context.assigns[:translations], &Map.get(&1, :id))
    operations = Enum.map(context.operations, &Map.get(&1, :action))

    assert translation_ids === [translation.id]
    assert operations === ["correct_conflict"]
  end

  test "builder fetch translations and ignore corrected translation", %{revision: revision} do
    Factory.insert(Translation, key: "a", proposed_text: "A", conflicted: false, revision_id: revision.id)

    context =
      %Context{}
      |> Context.assign(:revision, revision)
      |> RevisionCorrectAllBuilder.build()

    translation_ids = Enum.map(context.assigns[:translations], &Map.get(&1, :id))

    assert translation_ids === []
    assert context.operations === []
  end

  test "builder filters by from_version_id", %{revision: revision, project: project} do
    version = Factory.insert(Version, project_id: project.id, tag: "v1.0")

    main_translation =
      Factory.insert(Translation,
        key: "a",
        proposed_text: "A",
        conflicted: true,
        revision_id: revision.id,
        version_id: nil
      )

    Factory.insert(Translation,
      key: "a",
      proposed_text: "A version",
      conflicted: false,
      revision_id: revision.id,
      version_id: version.id,
      source_translation_id: main_translation.id
    )

    Factory.insert(Translation,
      key: "b",
      proposed_text: "B",
      conflicted: true,
      revision_id: revision.id,
      version_id: nil
    )

    context =
      %Context{}
      |> Context.assign(:revision, revision)
      |> Context.assign(:version_id, nil)
      |> Context.assign(:from_version_id, version.id)
      |> RevisionCorrectAllBuilder.build()

    translation_ids = Enum.map(context.assigns[:translations], &Map.get(&1, :id))

    assert translation_ids === [main_translation.id]
    assert length(context.operations) === 1
  end
end
