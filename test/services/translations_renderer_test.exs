defmodule AccentTest.TranslationsRenderer do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Document
  alias Accent.Language
  alias Accent.ProjectCreator
  alias Accent.Repo
  alias Accent.Translation
  alias Accent.TranslationsRenderer
  alias Accent.User

  setup do
    user = Factory.insert(User)
    language = Factory.insert(Language)

    {:ok, project} =
      ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)

    revision =
      project
      |> Repo.preload(:revisions)
      |> Map.get(:revisions)
      |> hd()
      |> Repo.preload(:language)

    {:ok, [project: project, revision: revision]}
  end

  test "render json with filename", %{project: project, revision: revision} do
    document = Factory.insert(Document, project_id: project.id, path: "my-test", format: "json")

    translation =
      Factory.insert(Translation,
        key: "a",
        proposed_text: "B",
        corrected_text: "A",
        revision_id: revision.id,
        document_id: document.id
      )

    %{render: render} =
      TranslationsRenderer.render_translations(%{
        master_translations: [],
        master_language: revision.language,
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
    document = Factory.insert(Document, project_id: project.id, path: "my-test", format: "json")

    translations =
      [
        Factory.insert(Translation,
          key: "a.nested.foo",
          proposed_text: "B",
          corrected_text: "A",
          revision_id: revision.id,
          document_id: document.id
        ),
        Factory.insert(Translation,
          key: "a.nested",
          proposed_text: "C",
          corrected_text: "D",
          revision_id: revision.id,
          document_id: document.id
        )
      ]

    %{render: render} =
      TranslationsRenderer.render_translations(%{
        master_translations: [],
        master_language: revision.language,
        translations: translations,
        document: document,
        language: revision.language
      })

    assert render == ""
  end

  if Langue.Formatter.Rails.enabled?() do
    test "render rails with locale", %{project: project, revision: revision} do
      document = Factory.insert(Document, project_id: project.id, path: "my-test", format: "rails_yml")

      translation =
        Factory.insert(Translation,
          key: "a",
          proposed_text: "A",
          corrected_text: "A",
          revision_id: revision.id,
          document_id: document.id
        )

      %{render: render} =
        TranslationsRenderer.render_translations(%{
          master_translations: [],
          master_language: revision.language,
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

  test "render xliff and revision overrides on source revision", %{project: project, revision: revision} do
    revision = Repo.update!(Ecto.Changeset.change(revision, %{slug: "testtest"}))
    document = Factory.insert(Document, project_id: project.id, path: "my-test", format: "xliff_1_2")

    translation =
      Factory.insert(Translation,
        key: "a",
        proposed_text: "A",
        corrected_text: "A",
        revision_id: revision.id,
        document_id: document.id
      )

    %{render: render} =
      TranslationsRenderer.render_translations(%{
        master_translations: [
          %Translation{
            key: "a",
            corrected_text: "master A"
          }
        ],
        master_language: Accent.Revision.language(revision),
        translations: [translation],
        document: document,
        language: %Language{slug: "fr"}
      })

    expected_render = """
    <file original=\"my-test\" datatype=\"plaintext\" source-language=\"testtest\" target-language=\"fr\">
      <body>
        <trans-unit id=\"a\">
          <source>master A</source>
          <target>A</target>
        </trans-unit>
      </body>
    </file>
    """

    assert render == expected_render
  end
end
