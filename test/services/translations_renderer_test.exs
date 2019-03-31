defmodule AccentTest.TranslationsRenderer do
  use Accent.RepoCase

  alias Accent.{
    Document,
    Language,
    ProjectCreator,
    Repo,
    Translation,
    TranslationsRenderer,
    User
  }

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)

    revision =
      project
      |> Repo.preload(:revisions)
      |> Map.get(:revisions)
      |> hd()
      |> Repo.preload(:language)

    {:ok, [project: project, revision: revision]}
  end

  test "render json with filename", %{project: project, revision: revision} do
    document = Repo.insert!(%Document{project_id: project.id, path: "my-test", format: "json"})

    translation =
      %Translation{
        key: "a",
        proposed_text: "B",
        corrected_text: "A",
        revision_id: revision.id,
        document_id: document.id
      }
      |> Repo.insert!()

    %{render: render} =
      TranslationsRenderer.render(%{
        master_translations: [],
        master_revision: revision,
        translations: [translation],
        document: document,
        language: revision.language
      })

    expected_render = """
    {
      "a": "A"
    }
    """

    assert render == expected_render
  end

  test "render json with runtime error", %{project: project, revision: revision} do
    document = Repo.insert!(%Document{project_id: project.id, path: "my-test", format: "json"})

    translations =
      [
        %Translation{
          key: "a.nested.foo",
          proposed_text: "B",
          corrected_text: "A",
          revision_id: revision.id,
          document_id: document.id
        },
        %Translation{
          key: "a.nested",
          proposed_text: "C",
          corrected_text: "D",
          revision_id: revision.id,
          document_id: document.id
        }
      ]
      |> Enum.map(&Repo.insert!/1)

    %{render: render} =
      TranslationsRenderer.render(%{
        master_translations: [],
        master_revision: revision,
        translations: translations,
        document: document,
        language: revision.language
      })

    assert render == ""
  end

  test "render rails with locale", %{project: project, revision: revision} do
    document = Repo.insert!(%Document{project_id: project.id, path: "my-test", format: "rails_yml"})

    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        corrected_text: "A",
        revision_id: revision.id,
        document_id: document.id
      }
      |> Repo.insert!()

    %{render: render} =
      TranslationsRenderer.render(%{
        master_translations: [],
        master_revision: revision,
        translations: [translation],
        document: document,
        language: %Language{slug: "fr"}
      })

    expected_render = """
    "fr":
      "a": "A"
    """

    assert render == expected_render
  end
end
