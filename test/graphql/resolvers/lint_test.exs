defmodule AccentTest.GraphQL.Resolvers.Lint do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.GraphQL.Resolvers.Lint, as: Resolver
  alias Accent.Language
  alias Accent.Lint.Message
  alias Accent.Lint.Replacement
  alias Accent.Project
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User

  defmodule PlugConn do
    @moduledoc false
    defstruct [:assigns]
  end

  setup do
    user = Factory.insert(User)
    french_language = Factory.insert(Language)
    project = Factory.insert(Project)

    revision =
      Factory.insert(Revision, language_id: french_language.id, project_id: project.id, master: true, slug: "fr")

    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, [user: user, project: project, revision: revision, context: context]}
  end

  test "lint", %{revision: revision, context: context} do
    master_translation =
      Factory.insert(Translation,
        revision: revision,
        conflicted: false,
        key: "ok2",
        corrected_text: "bar foo",
        proposed_text: "bar"
      )

    translation =
      Factory.insert(Translation,
        revision: revision,
        master_translation: master_translation,
        conflicted: false,
        key: "ok",
        corrected_text: " bar foo",
        proposed_text: "bar"
      )

    {:ok, result} = Resolver.lint_batched_translation(translation, %{}, context)

    assert result === [
             %Message{
               replacement: %Replacement{value: "bar foo", label: "bar foo"},
               check: :leading_spaces,
               text: " bar foo"
             }
           ]
  end
end
