defmodule Accent.GraphQL.Resolvers.Translation do
  @moduledoc false
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  alias Accent.Document
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

  require Query

  @internal_nested_separator ~r/__KEY__(\d+)/
  @typep translation_operation :: {:ok, %{translation: Translation.t() | nil, errors: [String.t()] | nil}}

  @spec key(Translation.t(), map(), GraphQLContext.t()) :: {:ok, String.t()}
  def key(translation, _, _) do
    translation
    |> Map.get(:key)
    |> String.replace(@internal_nested_separator, "[\\1]")
    |> then(&{:ok, &1})
  end

  def batch_translation_ids(grouped_translation, _args, _resolution) do
    ids = Enum.reject(grouped_translation.translation_ids, &is_nil/1)
    index_map = grouped_translation.revision_ids |> Enum.with_index() |> Map.new()

    batch(
      {__MODULE__, :from_translation_ids},
      ids,
      fn batch_results ->
        translations =
          Map.get(batch_results, {grouped_translation.key, grouped_translation.document_id}, [])

        translations =
          Enum.sort_by(translations, fn translation ->
            Map.get(index_map, translation.revision_id)
          end)

        {:ok, translations}
      end
    )
  end

  def from_translation_ids(_, ids) do
    ids = Enum.map(List.flatten(ids), &Ecto.UUID.cast!(&1))

    query =
      Query.from(translations in Translation,
        preload: [:revision],
        where: translations.id in ^ids
      )

    query
    |> Repo.all()
    |> Enum.group_by(&{&1.key, &1.document_id})
  end

  def batch_document(grouped_translation, _args, _resolution) do
    batch({__MODULE__, :from_document_id}, grouped_translation.document_id, fn batch_results ->
      [document | _] = Map.get(batch_results, grouped_translation.document_id)
      {:ok, document}
    end)
  end

  def from_document_id(_, ids) do
    query = Query.from(documents in Document, where: documents.id in ^ids)

    query
    |> Repo.all()
    |> Enum.group_by(& &1.id)
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
      |> Paginated.paginate(args)

    {:ok, Paginated.format(translations)}
  end

  @spec list_grouped_project(Project.t(), map(), GraphQLContext.t()) :: {:ok, struct()}
  def list_grouped_project(project, args, _) do
    total_entries =
      Translation
      |> list_grouped_count(args, project.id)
      |> Repo.all()
      |> Enum.count()

    {translations_query, revision_ids} =
      list_grouped(Translation, args, project.id)

    translations = Paginated.paginate(translations_query, args, total_entries: total_entries)
    translations = %{translations | entries: put_in(translations.entries, [Access.all(), :revision_ids], revision_ids)}
    revisions = grouped_related_revisions(Map.put(args, :project_id, project.id))
    revisions = Enum.map(revision_ids, fn revision_id -> Enum.find(revisions, &(&1.id === revision_id)) end)

    {:ok, Map.put(Paginated.format(translations), :revisions, revisions)}
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

  defp grouped_related_revisions(args) do
    query_revision_ids =
      if Enum.empty?(args[:related_revisions]) do
        Query.from(
          revisions in Revision,
          where: revisions.project_id == ^args[:project_id],
          order_by: [desc: :master, asc: :inserted_at],
          limit: 2
        )
      else
        Query.from(
          revisions in Revision,
          where: revisions.id in ^args[:related_revisions],
          order_by: [asc: :inserted_at]
        )
      end

    Repo.all(query_revision_ids)
  end

  defp grouped_related_query(schema, args, project_id) do
    revision_ids =
      if Enum.empty?(args[:related_revisions]) do
        Enum.map(grouped_related_revisions(Map.put(args, :project_id, project_id)), & &1.id)
      else
        args[:related_revisions]
      end

    query =
      schema
      |> TranslationScope.from_version(args[:version])
      |> TranslationScope.from_project(project_id)
      |> TranslationScope.from_revisions(revision_ids)
      |> TranslationScope.active()
      |> TranslationScope.not_locked()

    {query, revision_ids}
  end

  defp list_grouped_count(schema, args, project_id) do
    query = list_base_query(schema, args, project_id)
    {related_query, revision_ids} = grouped_related_query(schema, args, project_id)

    query =
      Query.from(
        translations in query,
        left_join: related_translations in subquery(related_query),
        as: :related_translations,
        on:
          related_translations.revision_id in ^revision_ids and
            related_translations.key == translations.key and
            related_translations.document_id == translations.document_id,
        distinct: [translations.key, translations.document_id],
        select: translations.key,
        group_by: [translations.key, translations.document_id]
      )

    if args[:is_conflicted] do
      Query.from([related_translations: related_translations] in query,
        having: fragment("array_agg(distinct(?))", related_translations.conflicted) != [false]
      )
    else
      query
    end
  end

  defp list_grouped(schema, args, project_id) do
    query = list_base_query(schema, args, project_id)
    {related_query, revision_ids} = grouped_related_query(schema, args, project_id)

    query =
      Query.from(
        translations in query,
        left_join: related_translations in subquery(related_query),
        as: :related_translations,
        on:
          related_translations.revision_id in ^revision_ids and
            related_translations.key == translations.key and
            related_translations.document_id == translations.document_id,
        distinct: translations.key,
        select: %{
          key: translations.key,
          document_id: translations.document_id,
          translation_ids: fragment("array_agg(distinct(?))", related_translations.id)
        },
        group_by: [translations.key, translations.document_id]
      )

    query =
      if args[:is_conflicted] do
        Query.from([related_translations: related_translations] in query,
          having: fragment("array_agg(distinct(?))", related_translations.conflicted) != [false]
        )
      else
        query
      end

    {query, revision_ids}
  end

  defp list(schema, args, project_id) do
    schema
    |> list_base_query(args, project_id)
    |> Query.distinct(true)
    |> Query.preload(:revision)
  end

  defp list_base_query(schema, args, project_id) do
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
    |> TranslationScope.from_project(project_id)
  end
end
