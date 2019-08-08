defmodule AccentTest.Movement.Builders.RevisionCorrectAll do
  use Accent.RepoCase

  alias Accent.{
    Language,
    ProjectCreator,
    Repo,
    Translation,
    User
  }

  alias Movement.Builders.RevisionCorrectAll, as: RevisionCorrectAllBuilder

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "French", slug: Ecto.UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)
    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()

    {:ok, [revision: revision]}
  end

  test "builder fetch translations and correct conflict", %{revision: revision} do
    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        conflicted: true,
        revision_id: revision.id
      }
      |> Repo.insert!()

    context =
      %Movement.Context{}
      |> Movement.Context.assign(:revision, revision)
      |> RevisionCorrectAllBuilder.build()

    translation_ids = context.assigns[:translations] |> Enum.map(&Map.get(&1, :id))
    operations = context.operations |> Enum.map(&Map.get(&1, :action))

    assert translation_ids === [translation.id]
    assert operations === ["correct_conflict"]
  end

  test "builder fetch translations and ignore corrected translation", %{revision: revision} do
    %Translation{
      key: "a",
      proposed_text: "A",
      conflicted: false,
      revision_id: revision.id
    }
    |> Repo.insert!()

    context =
      %Movement.Context{}
      |> Movement.Context.assign(:revision, revision)
      |> RevisionCorrectAllBuilder.build()

    translation_ids = context.assigns[:translations] |> Enum.map(&Map.get(&1, :id))

    assert translation_ids === []
    assert context.operations === []
  end
end
