defmodule Accent.GraphQL.Resolvers.Lint do
  @moduledoc false
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  alias Absinthe.Middleware.Batch
  alias Accent.Plugs.GraphQLContext
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Scopes.Revision, as: RevisionScope
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Translation

  require Ecto.Query

  @spec create_project_lint_entry(Project.t(), map(), GraphQLContext.t()) ::
          {:middleware, Batch, any()}
  def create_project_lint_entry(_project, args, _resolution) do
    Accent.Lint.create_lint_entry(args)
  end

  @spec lint_translation(Translation.t(), map(), GraphQLContext.t()) :: {:middleware, Batch, any()}
  def lint_translation(translation, args, _resolution) do
    batch({__MODULE__, :preload_translations}, translation, fn {batch_results, lint_entries} ->
      translation = Map.get(batch_results, translation.id)
      lint_batched_translation(translation, args, lint_entries)
    end)
  end

  def lint_batched_translation(translation, args, lint_entries) do
    translation = overwrite_text_args(translation, args)
    language_slug = translation.revision.slug || translation.revision.language.slug

    entry =
      Translation.to_langue_entry(
        translation,
        translation.master_translation,
        translation.revision.master,
        language_slug
      )

    [{_, messages}] = Accent.Lint.lint([entry], %Accent.Lint.Config{lint_entries: lint_entries})

    {:ok, messages}
  end

  def preload_translations(_, [translation | _] = translations) do
    translations = Repo.preload(translations, [:document, [revision: :language]])

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
      |> TranslationScope.from_version(translation.version_id)
      |> TranslationScope.active()
      |> Repo.all()
      |> Map.new(&{{&1.key, &1.document_id}, &1})

    translations =
      Enum.reduce(translations, %{}, fn translation, acc ->
        master_translation =
          Map.get(master_translations, {translation.key, translation.document_id})

        Map.put(acc, translation.id, %{translation | master_translation: master_translation})
      end)

    lint_entries = Repo.all(Ecto.assoc(project, [:lint_entries]))

    {translations, lint_entries}
  end

  defp overwrite_text_args(translation, %{text: text}) when is_binary(text) do
    %{translation | corrected_text: text}
  end

  defp overwrite_text_args(translation, _) do
    translation
  end
end
