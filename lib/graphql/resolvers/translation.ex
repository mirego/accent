defmodule Accent.GraphQL.Resolvers.Translation do
  require Ecto.Query
  alias Ecto.Query

  alias Accent.Scopes.Translation, as: TranslationScope

  alias Movement.Builders.TranslationCorrectConflict, as: TranslationCorrectConflictBuilder
  alias Movement.Builders.TranslationUncorrectConflict, as: TranslationUncorrectConflictBuilder
  alias Movement.Builders.TranslationUpdate, as: TranslationUpdateBuilder
  alias Movement.Context
  alias Movement.Persisters.Base, as: BasePersister

  alias Accent.{
    GraphQL.Paginated,
    Plugs.GraphQLContext,
    Project,
    Repo,
    Revision,
    Translation
  }

  @internal_nested_separator ~r/__KEY__(\d)/
  @typep translation_operation :: {:ok, %{translation: Translation.t() | nil, errors: [String.t()] | nil}}

  @spec key(Translation.t(), map(), GraphQLContext.t()) :: {:ok, String.t()}
  def key(translation, _, _) do
    translation
    |> Map.get(:key)
    |> String.replace(@internal_nested_separator, "[\\1]")
    |> (&{:ok, &1}).()
  end

  @spec correct(Translation.t(), %{text: String.t()}, GraphQLContext.t()) :: translation_operation
  def correct(translation, %{text: text}, info) do
    %Context{}
    |> Context.assign(:translation, translation)
    |> Context.assign(:text, text)
    |> Context.assign(:user_id, info.context[:conn].assigns[:current_user].id)
    |> TranslationCorrectConflictBuilder.build()
    |> (&fn -> BasePersister.execute(&1) end).()
    |> Repo.transaction()
    |> case do
      {:ok, {_context, [translation]}} ->
        {:ok, %{translation: translation, errors: nil}}

      {:error, _reason} ->
        {:ok, %{translation: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec uncorrect(Translation.t(), map(), GraphQLContext.t()) :: translation_operation
  def uncorrect(translation, _, info) do
    %Context{}
    |> Context.assign(:translation, translation)
    |> Context.assign(:user_id, info.context[:conn].assigns[:current_user].id)
    |> TranslationUncorrectConflictBuilder.build()
    |> (&fn -> BasePersister.execute(&1) end).()
    |> Repo.transaction()
    |> case do
      {:ok, {_context, [translation]}} ->
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
    |> (&fn -> BasePersister.execute(&1) end).()
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
      |> TranslationScope.active()
      |> TranslationScope.not_locked()
      |> TranslationScope.from_revision(revision.id)
      |> TranslationScope.from_search(args[:query])
      |> TranslationScope.from_document(args[:document] || :all)
      |> TranslationScope.parse_order(args[:order])
      |> TranslationScope.parse_conflicted(args[:is_conflicted])
      |> TranslationScope.parse_added_last_sync(args[:is_added_last_sync], revision.project_id)
      |> TranslationScope.parse_not_empty(args[:is_text_not_empty])
      |> TranslationScope.parse_empty(args[:is_text_empty])
      |> TranslationScope.parse_commented_on(args[:is_commented_on])
      |> TranslationScope.from_version(args[:version])
      |> Query.preload(:revision)
      |> Paginated.paginate(args)

    translations = %{translations | entries: add_related_translations(translations.entries, args[:reference_revision], args[:version])}

    {:ok, Paginated.format(translations)}
  end

  @spec related_translations(Translation.t(), map(), struct()) :: {:ok, [Translation.t()]}
  def related_translations(translation, _, _) do
    revision =
      translation
      |> Ecto.assoc(:revision)
      |> Repo.one()

    revision_ids =
      Project
      |> Repo.get!(revision.project_id)
      |> Ecto.assoc(:revisions)
      |> Query.select([r], r.id)
      |> Repo.all()

    translations =
      Translation
      |> TranslationScope.from_revisions(revision_ids)
      |> TranslationScope.from_key(translation.key)
      |> TranslationScope.from_document(translation.document_id)
      |> TranslationScope.not_id(translation.id)
      |> TranslationScope.from_version(translation.version_id)
      |> Repo.all()

    {:ok, translations}
  end

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
        |> TranslationScope.from_key(translation.key)
        |> TranslationScope.from_document(translation.document_id)
        |> TranslationScope.from_version(translation.version_id)
        |> Repo.one()
        |> (&{:ok, &1}).()
    end
  end

  defp add_related_translations(entries, nil, _), do: entries

  defp add_related_translations(entries, reference_revision, version) do
    reference_revision = Repo.get(Revision, reference_revision)

    reference_translations =
      Translation
      |> TranslationScope.active()
      |> TranslationScope.from_revision(reference_revision.id)
      |> TranslationScope.from_keys(Enum.map(entries, &Map.get(&1, :key)))
      |> TranslationScope.from_version(version)
      |> Repo.all()
      |> Enum.group_by(&Map.get(&1, :key))

    Enum.map(entries, fn translation ->
      case reference_translations[translation.key] do
        [reference_translation | _tail] ->
          Map.put(translation, :related_translation, reference_translation)

        _ ->
          translation
      end
    end)
  end
end
