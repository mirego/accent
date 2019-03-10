defmodule AccentTest.Movement.Builders.RevisionUncorrectAll do
  use Accent.RepoCase

  alias Movement.Builders.RevisionUncorrectAll, as: RevisionUncorrectAllBuilder

  alias Accent.{
    Language,
    ProjectCreator,
    Repo,
    Translation,
    User
  }

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)
    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()

    {:ok, [revision: revision]}
  end

  test "builder fetch translations and uncorrect conflict", %{revision: revision} do
    translation =
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
      |> RevisionUncorrectAllBuilder.build()

    translation_ids = context.assigns[:translations] |> Enum.map(&Map.get(&1, :id))
    operations = context.operations |> Enum.map(&Map.get(&1, :action))

    assert translation_ids === [translation.id]
    assert operations === ["uncorrect_conflict"]
  end

  test "builder fetch translations and ignore conflicted translation", %{revision: revision} do
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
      |> RevisionUncorrectAllBuilder.build()

    translation_ids = context.assigns[:translations] |> Enum.map(&Map.get(&1, :id))

    assert translation_ids === []
    assert context.operations === []
  end
end
