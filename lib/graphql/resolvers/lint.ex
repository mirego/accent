defmodule Accent.GraphQL.Resolvers.Lint do
  require Ecto.Query

  import Absinthe.Resolution.Helpers, only: [batch: 3]

  alias Accent.Scopes.Revision, as: RevisionScope
  alias Accent.Scopes.Translation, as: TranslationScope

  alias Accent.{
    Language,
    Plugs.GraphQLContext,
    Repo,
    Translation
  }

  @spec lint_translation(Translation.t(), map(), GraphQLContext.t()) :: {:ok, Paginated.t(Language.Entry.t())}
  def lint_translation(translation, args, _) do
    batch({__MODULE__, :preload_translations}, translation, fn batch_results ->
      translation = Map.get(batch_results, translation.id)
      translation = overwrite_text_args(translation, args)
      entry = Translation.to_langue_entry(translation, translation.master_translation, translation.revision.master)
      [lint] = Accent.Lint.lint([entry])

      {:ok, lint.messages}
    end)
  end

  def preload_translations(_, [translation | _] = translations) do
    translations = Repo.preload(translations, :revision)

    project =
      translation
      |> Ecto.assoc(:project)
      |> Repo.one()

    master_revision =
      project
      |> Ecto.assoc(:revisions)
      |> RevisionScope.master()
      |> Repo.one()

    master_translations =
      Accent.Translation
      |> TranslationScope.from_project(project.id)
      |> TranslationScope.from_revision(master_revision.id)
      |> TranslationScope.active()
      |> Repo.all()

    Enum.reduce(translations, %{}, fn translation, acc ->
      master_translation = Enum.find(master_translations, &(&1.key === translation.key))
      Map.put(acc, translation.id, %{translation | master_translation: master_translation})
    end)
  end

  defp overwrite_text_args(translation, %{text: text}) when is_binary(text) do
    %{translation | corrected_text: text}
  end

  defp overwrite_text_args(translation, _) do
    translation
  end
end
