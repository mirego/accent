defmodule Accent.GraphQL.Resolvers.Translation do
  @moduledoc false
  alias Accent.GraphQL.Paginated
  alias Accent.Plugs.GraphQLContext
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Translation
  alias Ecto.Query
  alias Movement.Builders.TranslationCorrectConflict, as: TranslationCorrectConflictBuilder
  alias Movement.Builders.TranslationUncorrectConflict, as: TranslationUncorrectConflictBuilder
  alias Movement.Builders.TranslationUpdate, as: TranslationUpdateBuilder
  alias Movement.Context
  alias Movement.Persisters.Base, as: BasePersister

  require Ecto.Query

  @internal_nested_separator ~r/__KEY__(\d+)/
  @typep translation_operation :: {:ok, %{translation: Translation.t() | nil, errors: [String.t()] | nil}}

  @spec key(Translation.t(), map(), GraphQLContext.t()) :: {:ok, String.t()}
  def key(translation, _, _) do
    translation
    |> Map.get(:key)
    |> String.replace(@internal_nested_separator, "[\\1]")
    |> then(&{:ok, &1})
  end

  @spec correct(Translation.t(), %{text: String.t()}, GraphQLContext.t()) :: translation_operation
  def correct(translation, %{text: text}, info) do
    %Context{}
    |> Context.assign(:translation, translation)
    |> Context.assign(:text, text)
    |> Context.assign(:user_id, info.context[:conn].assigns[:current_user].id)
    |> TranslationCorrectConflictBuilder.build()
    |> then(&fn -> BasePersister.execute(&1) end)
    |> Repo.transaction()
    |> case do
      {:ok, {_context, _}} ->
        translation =
          Translation
          |> Query.where(id: ^translation.id)
          |> Repo.one()
          |> Repo.preload(:revision)

        {:ok, %{translation: translation, errors: nil}}

      {:error, _reason} ->
        {:ok, %{translation: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec uncorrect(Translation.t(), map(), GraphQLContext.t()) :: translation_operation
  def uncorrect(translation, %{text: text}, info) do
    %Context{}
    |> Context.assign(:translation, translation)
    |> Context.assign(:text, text)
    |> Context.assign(:user_id, info.context[:conn].assigns[:current_user].id)
    |> TranslationUncorrectConflictBuilder.build()
    |> then(&fn -> BasePersister.execute(&1) end)
    |> Repo.transaction()
    |> case do
      {:ok, {_context, _}} ->
        translation =
          Translation
          |> Query.where(id: ^translation.id)
          |> Repo.one()
          |> Repo.preload(:revision)

        {:ok, %{translation: translation, errors: nil}}

      {:error, _reason} ->
        {:ok, %{translation: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec update(Translation.t(), %{text: String.t()}, GraphQLContext.t()) :: translation_operation
  def update(translation, %{text: text}, info) do
    %Context{}
    |> Context.assign(:translation, translation)
    |> Context.assign(:text, text)
    |> Context.assign(:user_id, info.context[:conn].assigns[:current_user].id)
    |> TranslationUpdateBuilder.build()
    |> then(&fn -> BasePersister.execute(&1) end)
    |> Repo.transaction()
    |> case do
      {:ok, {_context, [translation]}} ->
        {:ok, %{translation: translation, errors: nil}}

      {:ok, _} ->
        {:ok, %{translation: translation, errors: nil}}

      {:error, _reason} ->
        {:ok, %{translation: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec show_project(Project.t(), %{id: String.t()}, GraphQLContext.t()) :: {:ok, Translation.t() | nil}
  def show_project(project, %{id: id}, _) do
    translation =
      Translation
      |> TranslationScope.from_project(project.id)
      |> Query.where(id: ^id)
      |> Repo.one()
      |> Repo.preload(:revision)

    {:ok, translation}
  end

  @spec list_revision(Revision.t(), map(), GraphQLContext.t()) :: {:ok, Paginated.t(Translation.t())}
  def list_revision(revision, args, _) do
    translations =
      Translation
      |> list(args, revision.project_id)
      |> TranslationScope.from_revision(revision.id)
      |> Paginated.paginate(args)

    {:ok, Paginated.format(translations)}
  end

  @spec list_project(Project.t(), map(), GraphQLContext.t()) :: {:ok, Paginated.t(Translation.t())}
  def list_project(project, args, _) do
    translations =
      Translation
      |> list(args, project.id)
      |> TranslationScope.from_project(project.id)
      |> Paginated.paginate(args)

    {:ok, Paginated.format(translations)}
  end

  @spec related_translations(Translation.t(), map(), struct()) :: {:ok, [Translation.t()]}
  def related_translations(translation, _, _) do
    translations =
      Translation
      |> TranslationScope.not_from_revision(translation.revision_id)
      |> TranslationScope.related_to(translation)
      |> Repo.all()

    {:ok, translations}
  end

  @spec editions(Translation.t(), map(), struct()) :: {:ok, [Translation.t()]}
  def editions(translation, _, _) do
    translations =
      Translation
      |> TranslationScope.editions(translation)
      |> Repo.all()

    {:ok, translations}
  end

  @spec master_translation(Translation.t(), map(), struct()) :: {:ok, Translation.t() | nil}
  def master_translation(translation, _, _) do
    translation
    |> Ecto.assoc(:revision)
    |> Repo.one()
    |> case do
      %{master_revision_id: nil, id: id} ->
        id

      %{master_revision_id: revision_id} ->
        revision_id

      _ ->
        nil
    end
    |> case do
      nil ->
        {:ok, nil}

      revision_id ->
        Translation
        |> TranslationScope.from_revision(revision_id)
        |> TranslationScope.related_to_one(translation)
        |> Repo.one()
        |> then(&{:ok, &1})
    end
  end

  defp list(schema, args, project_id) do
    schema
    |> TranslationScope.active()
    |> TranslationScope.not_locked()
    |> TranslationScope.from_search(args[:query])
    |> TranslationScope.from_document(args[:document] || :all)
    |> TranslationScope.parse_order(args[:order])
    |> TranslationScope.parse_conflicted(args[:is_conflicted])
    |> TranslationScope.parse_translated(args[:is_translated])
    |> TranslationScope.parse_added_last_sync(args[:is_added_last_sync], project_id, args[:document])
    |> TranslationScope.parse_not_empty(args[:is_text_not_empty])
    |> TranslationScope.parse_empty(args[:is_text_empty])
    |> TranslationScope.parse_commented_on(args[:is_commented_on])
    |> TranslationScope.from_version(args[:version])
    |> Query.distinct(true)
    |> Query.preload(:revision)
  end
end
