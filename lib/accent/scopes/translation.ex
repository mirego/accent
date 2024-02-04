defmodule Accent.Scopes.Translation do
  @moduledoc false
  import Ecto.Query

  alias Accent.Operation
  alias Accent.Repo
  alias Accent.Translation
  alias Ecto.Queryable

  @doc """
  Default ordering is by ascending key

  ## Examples

    iex> Accent.Scopes.Translation.parse_order(Accent.Translation, nil)
    #Ecto.Query<from t0 in Accent.Translation, order_by: [asc: t0.key]>
    iex> Accent.Scopes.Translation.parse_order(Accent.Translation, "key")
    #Ecto.Query<from t0 in Accent.Translation, order_by: [asc: t0.key]>
    iex> Accent.Scopes.Translation.parse_order(Accent.Translation, "-key")
    #Ecto.Query<from t0 in Accent.Translation, order_by: [desc: t0.key]>
    iex> Accent.Scopes.Translation.parse_order(Accent.Translation, "updated")
    #Ecto.Query<from t0 in Accent.Translation, order_by: [asc: t0.updated_at]>
    iex> Accent.Scopes.Translation.parse_order(Accent.Translation, "-updated")
    #Ecto.Query<from t0 in Accent.Translation, order_by: [desc: t0.updated_at]>
    iex> Accent.Scopes.Translation.parse_order(Accent.Translation, "index")
    #Ecto.Query<from t0 in Accent.Translation, order_by: [asc: t0.file_index]>
    iex> Accent.Scopes.Translation.parse_order(Accent.Translation, "-index")
    #Ecto.Query<from t0 in Accent.Translation, order_by: [desc: t0.file_index]>
  """
  @spec parse_order(Queryable.t(), any()) :: Queryable.t()
  def parse_order(query, "index"), do: from(query, order_by: [asc: :file_index])
  def parse_order(query, "-index"), do: from(query, order_by: [desc: :file_index])
  def parse_order(query, "key"), do: from(query, order_by: [asc: :key])
  def parse_order(query, "-key"), do: from(query, order_by: [desc: :key])
  def parse_order(query, "updated"), do: from(query, order_by: [asc: :updated_at])
  def parse_order(query, "-updated"), do: from(query, order_by: [desc: :updated_at])

  def parse_order(query, "master"),
    do:
      from(translations in query,
        inner_join: revisions in assoc(translations, :revision),
        inner_join: languages in assoc(revisions, :language),
        order_by: [
          fragment("(case when ? then 0 else 2 end) ASC", revisions.master),
          {:asc, revisions.name},
          {:asc, languages.name}
        ]
      )

  def parse_order(query, _), do: from(query, order_by: [asc: :key])

  def editions(query, translation) do
    query =
      from(
        translations in query,
        left_join: versions in assoc(translations, :version),
        where: [revision_id: ^translation.revision_id],
        order_by: [
          {:desc_nulls_first, versions.inserted_at}
        ]
      )

    if translation.version_id do
      from(translations in query,
        where:
          (translations.source_translation_id == ^translation.source_translation_id or
             translations.id == ^translation.source_translation_id) and
            translations.id != ^translation.id
      )
    else
      from(query, where: [source_translation_id: ^translation.id])
    end
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.removed(Accent.Translation)
    #Ecto.Query<from t0 in Accent.Translation, where: t0.removed == true>
  """
  @spec removed(Queryable.t()) :: Queryable.t()
  def removed(query), do: from(query, where: [removed: true])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.active(Accent.Translation)
    #Ecto.Query<from t0 in Accent.Translation, where: t0.removed == false>
  """
  @spec active(Queryable.t()) :: Queryable.t()
  def active(query), do: from(query, where: [removed: false])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.not_locked(Accent.Translation)
    #Ecto.Query<from t0 in Accent.Translation, where: t0.locked == false>
  """
  @spec not_locked(Queryable.t()) :: Queryable.t()
  def not_locked(query), do: from(query, where: [locked: false])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.parse_conflicted(Accent.Translation, nil)
    Accent.Translation
    iex> Accent.Scopes.Translation.parse_conflicted(Accent.Translation, false)
    #Ecto.Query<from t0 in Accent.Translation, where: t0.conflicted == false>
    iex> Accent.Scopes.Translation.parse_conflicted(Accent.Translation, true)
    #Ecto.Query<from t0 in Accent.Translation, where: t0.conflicted == true>
  """
  @spec parse_conflicted(Queryable.t(), nil | boolean()) :: Queryable.t()
  def parse_conflicted(query, nil), do: query
  def parse_conflicted(query, false), do: not_conflicted(query)
  def parse_conflicted(query, true), do: conflicted(query)

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.parse_translated(Accent.Translation, nil)
    Accent.Translation
    iex> Accent.Scopes.Translation.parse_translated(Accent.Translation, false)
    #Ecto.Query<from t0 in Accent.Translation, where: t0.translated == false>
    iex> Accent.Scopes.Translation.parse_translated(Accent.Translation, true)
    #Ecto.Query<from t0 in Accent.Translation, where: t0.translated == true>
  """
  @spec parse_translated(Queryable.t(), nil | boolean()) :: Queryable.t()
  def parse_translated(query, nil), do: query
  def parse_translated(query, false), do: not_translated(query)
  def parse_translated(query, true), do: translated(query)

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.parse_empty(Accent.Translation, nil)
    Accent.Translation
    iex> Accent.Scopes.Translation.parse_empty(Accent.Translation, true)
    #Ecto.Query<from t0 in Accent.Translation, where: t0.value_type in ^["empty", "null"] or t0.corrected_text == "">
  """
  @spec parse_empty(Queryable.t(), nil | boolean()) :: Queryable.t()
  def parse_empty(query, nil), do: query

  def parse_empty(query, true),
    do:
      from(translations in query,
        where: translations.value_type in ^["empty", "null"] or translations.corrected_text == ""
      )

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.parse_not_empty(Accent.Translation, nil)
    Accent.Translation
    iex> Accent.Scopes.Translation.parse_not_empty(Accent.Translation, true)
    #Ecto.Query<from t0 in Accent.Translation, where: t0.corrected_text != "">
  """
  @spec parse_not_empty(Queryable.t(), nil | boolean()) :: Queryable.t()
  def parse_not_empty(query, nil), do: query

  def parse_not_empty(query, true), do: from(translations in query, where: translations.corrected_text != "")

  @spec parse_added_last_sync(Queryable.t(), nil | boolean(), String.t(), String.t() | nil) ::
          Queryable.t()
  def parse_added_last_sync(query, nil, _, _), do: query

  def parse_added_last_sync(query, true, project_id, document_id) do
    from(
      operations in Operation,
      select: operations.id,
      where: [project_id: ^project_id],
      where: [action: ^"sync"],
      limit: 1,
      order_by: [desc: :inserted_at]
    )
    |> maybe_filter_last_sync_by_document(document_id)
    |> Repo.one()
    |> case do
      nil ->
        query

      last_sync_id ->
        from(
          translations in query,
          inner_join: operations in assoc(translations, :operations),
          where: operations.batch_operation_id == ^last_sync_id
        )
    end
  end

  defp maybe_filter_last_sync_by_document(query, nil), do: query

  defp maybe_filter_last_sync_by_document(query, document_id) do
    from(query, where: [document_id: ^document_id])
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.parse_commented_on(Accent.Translation, nil)
    Accent.Translation
    iex> Accent.Scopes.Translation.parse_commented_on(Accent.Translation, true)
    #Ecto.Query<from t0 in Accent.Translation, join: c1 in assoc(t0, :comments)>
  """
  @spec parse_commented_on(Queryable.t(), nil | boolean()) :: Queryable.t()
  def parse_commented_on(query, nil), do: query

  def parse_commented_on(query, true) do
    from(
      translations in query,
      inner_join: comments in assoc(translations, :comments)
    )
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.conflicted(Accent.Translation)
    #Ecto.Query<from t0 in Accent.Translation, where: t0.conflicted == true>
  """
  @spec conflicted(Queryable.t()) :: Queryable.t()
  def conflicted(query), do: from(query, where: [conflicted: true])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.not_conflicted(Accent.Translation)
    #Ecto.Query<from t0 in Accent.Translation, where: t0.conflicted == false>
  """
  @spec not_conflicted(Queryable.t()) :: Queryable.t()
  def not_conflicted(query), do: from(query, where: [conflicted: false])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.translated(Accent.Translation)
    #Ecto.Query<from t0 in Accent.Translation, where: t0.translated == true>
  """
  @spec translated(Queryable.t()) :: Queryable.t()
  def translated(query), do: from(query, where: [translated: true])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.not_translated(Accent.Translation)
    #Ecto.Query<from t0 in Accent.Translation, where: t0.translated == false>
  """
  @spec not_translated(Queryable.t()) :: Queryable.t()
  def not_translated(query), do: from(query, where: [translated: false])

  @spec related_to(Queryable.t(), Translation.t()) :: Queryable.t()
  def related_to(query, translation) do
    query
    |> from_key(translation.key)
    |> from_document(translation.document_id)
    |> from_version(translation.version_id)
    |> then(fn query ->
      if translation.removed, do: removed(query), else: active(query)
    end)
    |> distinct([translations], translations.revision_id)
    |> subquery()
    |> from()
    |> parse_order("master")
  end

  @spec related_to_one(Queryable.t(), Translation.t()) :: Queryable.t()
  def related_to_one(query, translation) do
    query
    |> related_to(translation)
    |> limit(1)
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.no_version(Accent.Translation)
    #Ecto.Query<from t0 in Accent.Translation, where: is_nil(t0.version_id)>
  """
  @spec no_version(Queryable.t()) :: Queryable.t()
  def no_version(query), do: from_version(query, nil)

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_version(Accent.Translation, nil)
    #Ecto.Query<from t0 in Accent.Translation, where: is_nil(t0.version_id)>
    iex> Accent.Scopes.Translation.from_version(Accent.Translation, "test")
    #Ecto.Query<from t0 in Accent.Translation, where: t0.version_id == ^"test">
  """
  @spec from_version(Queryable.t(), any()) :: Queryable.t()
  def from_version(query, nil), do: from(t in query, where: is_nil(t.version_id))
  def from_version(query, version_id), do: from(query, where: [version_id: ^version_id])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_revision(Accent.Translation, "test")
    #Ecto.Query<from t0 in Accent.Translation, where: t0.revision_id == ^"test">
  """
  @spec from_revision(Queryable.t(), String.t() | :all) :: Queryable.t()
  def from_revision(query, :all), do: query
  def from_revision(query, revision_id), do: from(query, where: [revision_id: ^revision_id])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_language(Accent.Translation, "test")
    #Ecto.Query<from t0 in Accent.Translation, join: r1 in assoc(t0, :revision), where: r1.language_id == ^\"test\">
  """
  @spec from_language(Queryable.t(), String.t()) :: Queryable.t()
  def from_language(query, language_id),
    do:
      from(translations in query,
        inner_join: revisions in assoc(translations, :revision),
        where: revisions.language_id == ^language_id
      )

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.not_from_revision(Accent.Translation, "test")
    #Ecto.Query<from t0 in Accent.Translation, where: t0.revision_id != ^"test">
  """
  @spec not_from_revision(Queryable.t(), String.t()) :: Queryable.t()
  def not_from_revision(query, nil), do: query

  def not_from_revision(query, revision_id), do: from(t in query, where: t.revision_id != ^revision_id)

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_revisions(Accent.Translation, ["test"])
    #Ecto.Query<from t0 in Accent.Translation, where: t0.revision_id in ^["test"]>
  """
  @spec from_revision(Queryable.t(), list(String.t())) :: Queryable.t()
  def from_revisions(query, revision_ids), do: from(t in query, where: t.revision_id in ^revision_ids)

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_project(Accent.Translation, "test")
    #Ecto.Query<from t0 in Accent.Translation, join: p1 in assoc(t0, :project), where: p1.id == ^"test">
  """
  @spec from_project(Queryable.t(), String.t()) :: Queryable.t()
  def from_project(query, project_id) do
    from(
      translation in query,
      inner_join: project in assoc(translation, :project),
      where: project.id == ^project_id
    )
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_document(Accent.Translation, nil)
    #Ecto.Query<from t0 in Accent.Translation, where: is_nil(t0.document_id)>
    iex> Accent.Scopes.Translation.from_document(Accent.Translation, :all)
    Accent.Translation
    iex> Accent.Scopes.Translation.from_document(Accent.Translation, "test")
    #Ecto.Query<from t0 in Accent.Translation, where: t0.document_id == ^"test">
  """
  @spec from_document(Queryable.t(), any()) :: Queryable.t()
  def from_document(query, nil), do: from(t in query, where: is_nil(t.document_id))
  def from_document(query, :all), do: query
  def from_document(query, document_id), do: from(query, where: [document_id: ^document_id])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_documents(Accent.Translation, ["test"])
    #Ecto.Query<from t0 in Accent.Translation, where: t0.document_id in ^["test"]>
  """
  @spec from_documents(Queryable.t(), list(String.t())) :: Queryable.t()
  def from_documents(query, document_ids), do: from(t in query, where: t.document_id in ^document_ids)

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_key(Accent.Translation, "test")
    #Ecto.Query<from t0 in Accent.Translation, where: t0.key == ^"test">
  """
  @spec from_key(Queryable.t(), String.t()) :: Queryable.t()
  def from_key(query, key), do: from(query, where: [key: ^key])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_keys(Accent.Translation, ["test"])
    #Ecto.Query<from t0 in Accent.Translation, where: t0.key in ^["test"]>
  """
  @spec from_keys(Queryable.t(), list(String.t())) :: Queryable.t()
  def from_keys(query, key_ids), do: from(t in query, where: t.key in ^key_ids)

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_search(Accent.Translation, "")
    Accent.Translation
    iex> Accent.Scopes.Translation.from_search(Accent.Translation, nil)
    Accent.Translation
    iex> Accent.Scopes.Translation.from_search(Accent.Translation, 1234)
    Accent.Translation
    iex> Accent.Scopes.Translation.from_search(Accent.Translation, "test")
    #Ecto.Query<from t0 in Accent.Translation, where: ilike(t0.corrected_text, ^\"%test%\") or (ilike(t0.key, ^\"%test%\") or ^false)>
  """
  @spec from_search(Queryable.t(), any()) :: Queryable.t()
  def from_search(query, nil), do: query
  def from_search(query, term) when term === "", do: query
  def from_search(query, term) when not is_binary(term), do: query

  def from_search(query, search_term) do
    from_search_id(
      Accent.Scopes.Search.from_search(query, search_term, [:key, :corrected_text]),
      search_term
    )
  end

  defp from_search_id(query, key) do
    case Ecto.UUID.cast(key) do
      {:ok, uuid} -> from(t in query, or_where: [id: ^uuid])
      _ -> query
    end
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.select_key_text(Accent.Translation)
    #Ecto.Query<from t0 in Accent.Translation, select: %{id: t0.id, key: t0.key, updated_at: t0.updated_at, corrected_text: t0.corrected_text}>
  """
  @spec select_key_text(Queryable.t()) :: Queryable.t()
  def select_key_text(query) do
    from(
      translation in query,
      select: %{
        id: translation.id,
        key: translation.key,
        updated_at: translation.updated_at,
        corrected_text: translation.corrected_text
      }
    )
  end
end
