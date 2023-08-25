defmodule AccentTest.Movement.Builders.RevisionMerge do
  @moduledoc false
  use Accent.RepoCase

  alias Accent.Document
  alias Accent.Language
  alias Accent.ProjectCreator
  alias Accent.Repo
  alias Accent.Translation
  alias Accent.User
  alias Movement.Builders.RevisionMerge, as: RevisionMergeBuilder
  alias Movement.Context

  @user %User{email: "test@test.com"}

  test "builder fetch translations and use comparer" do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})

    {:ok, project} =
      ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)

    revision = project |> Repo.preload(revisions: [:language]) |> Map.get(:revisions) |> hd()
    document = Repo.insert!(%Document{project_id: project.id, path: "test", format: "json"})

    translation =
      Repo.insert!(%Translation{key: "a", proposed_text: "A", revision_id: revision.id, document_id: document.id})

    entries = [%Langue.Entry{key: "a", value: "B", value_type: "string"}]

    context =
      %Context{entries: entries}
      |> Context.assign(:comparer, fn x, _y -> %Movement.Operation{action: "merge_on_proposed", key: x.key} end)
      |> Context.assign(:document, document)
      |> Context.assign(:project, project)
      |> Context.assign(:revision, revision)
      |> RevisionMergeBuilder.build()

    translation_ids = Enum.map(context.assigns[:translations], &Map.get(&1, :id))
    operations = Enum.map(context.operations, &Map.get(&1, :action))

    assert translation_ids === [translation.id]
    assert operations === ["merge_on_proposed"]
  end
end
