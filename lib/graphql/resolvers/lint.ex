defmodule Accent.GraphQL.Resolvers.Lint do
  @moduledoc false
  import Absinthe.Resolution.Helpers, only: [batch: 3]
  import Accent.GraphQL.Response

  alias Absinthe.Middleware.Batch
  alias Accent.GraphQL.Paginated
  alias Accent.Lint, as: LintContext
  alias Accent.Plugs.GraphQLContext
  alias Accent.Project
  alias Accent.ProjectLintEntry
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Scopes.ProjectLintEntry, as: ProjectLintEntryScope
  alias Accent.Scopes.Revision, as: RevisionScope
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Translation
  alias Ecto.Query

  require Query

  @spec create_project_lint_entry(Project.t(), map(), GraphQLContext.t()) ::
          {:middleware, Batch, any()}
  def create_project_lint_entry(_project, args, _resolution) do
    LintContext.create_lint_entry(args)
  end

  @spec update_project_lint_entry(ProjectLintEntry.t(), map(), GraphQLContext.t()) :: {:ok, any()}
  def update_project_lint_entry(lint_entry, args, _resolution) do
    lint_entry
    |> LintContext.update_lint_entry(args)
    |> build()
  end

  @spec delete_project_lint_entry(ProjectLintEntry.t(), map(), GraphQLContext.t()) :: {:ok, any()}
  def delete_project_lint_entry(lint_entry, _args, _resolution) do
    lint_entry
    |> LintContext.delete_lint_entry()
    |> build()
  end

  @spec list_project(Project.t(), map(), GraphQLContext.t()) :: {:ok, Paginated.t(ProjectLintEntry.t())}
  def list_project(project, args, info) do
    ProjectLintEntry
    |> ProjectLintEntryScope.from_project(project.id)
    |> Paginated.paginate(args, info: info)
    |> Paginated.format()
    |> then(&{:ok, &1})
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

    [{_, messages}] = LintContext.lint([entry], %LintContext.Config{lint_entries: lint_entries})

    {:ok, messages}
  end

  def preload_translations(_, [translation | _] = translations) do
    translations = Repo.preload(translations, [:document, [revision: :language]])
    project_id = hd(translations).revision.project_id

    master_revision_id =
      Revision
      |> RevisionScope.master()
      |> Query.where(project_id: ^project_id)
      |> Query.select([r], r.id)
      |> Query.limit(1)
      |> Repo.one()

    master_translations = master_translations(master_revision_id, translation.version_id, translations)

    translations =
      Map.new(translations, fn translation ->
        master_translation = Map.get(master_translations, {translation.key, translation.document_id})
        {translation.id, %{translation | master_translation: master_translation}}
      end)

    lint_entries = Repo.all(Query.where(ProjectLintEntry, project_id: ^project_id))

    {translations, lint_entries}
  end

  defp master_translations(nil, _version_id, _translations), do: %{}

  defp master_translations(master_revision_id, version_id, translations) do
    keys = translations |> Enum.map(& &1.key) |> Enum.uniq()

    Translation
    |> TranslationScope.from_revision(master_revision_id)
    |> TranslationScope.from_version(version_id)
    |> TranslationScope.from_keys(keys)
    |> TranslationScope.active()
    |> Query.select([t], %{key: t.key, document_id: t.document_id, corrected_text: t.corrected_text})
    |> Repo.all()
    |> Map.new(&{{&1.key, &1.document_id}, &1})
  end

  defp overwrite_text_args(translation, %{text: text}) when is_binary(text) do
    %{translation | corrected_text: text}
  end

  defp overwrite_text_args(translation, _) do
    translation
  end
end
