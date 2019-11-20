defmodule Accent.GraphQL.Resolvers.Lint do
  require Ecto.Query

  alias Accent.Scopes.Revision, as: RevisionScope
  alias Accent.Scopes.Translation, as: TranslationScope

  alias Accent.{
    Plugs.GraphQLContext,
    Repo,
    Translation
  }

  @spec lint_translation(Translation.t(), map(), GraphQLContext.t()) :: {:ok, Paginated.t(Operation.t())}
  def lint_translation(translation, args, _) do
    project =
      translation
      |> Ecto.assoc(:project)
      |> Repo.one()

    master_revision =
      project
      |> Ecto.assoc(:revisions)
      |> RevisionScope.master()
      |> Repo.one()

    translation =
      translation
      |> Repo.preload(revision: [:language])
      |> overwrite_text_args(args)

    master_translation =
      Translation
      |> TranslationScope.from_revision(master_revision.id)
      |> TranslationScope.from_document(translation.document_id)
      |> TranslationScope.from_version(translation.version_id)
      |> TranslationScope.from_key(translation.key)
      |> Repo.one()

    entry = Translation.to_langue_entry(translation, master_translation, translation.revision.master)
    [lint] = Accent.Lint.lint([entry], language: translation.revision.language.slug)

    {:ok, lint.messages}
  end

  defp overwrite_text_args(translation, %{text: text}) when is_binary(text) do
    %{translation | corrected_text: text}
  end

  defp overwrite_text_args(translation, _) do
    translation
  end
end
