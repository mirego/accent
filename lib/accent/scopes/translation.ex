defmodule Accent.Scopes.Translation do
  import Ecto.Query

  alias Ecto.Queryable
  alias Accent.{Operation, Repo}

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.not_id(Accent.Translation, "test")
    #Ecto.Query<from t0 in Accent.Translation, where: t0.id != ^"test">
  """
  @spec not_id(Queryable.t(), String.t()) :: Queryable.t()
  def not_id(query, id) do
    from(t in query, where: t.id != ^id)
  end

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
  def parse_order(query, _), do: from(query, order_by: [asc: :key])

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

    iex> Accent.Scopes.Translation.parse_empty(Accent.Translation, nil)
    Accent.Translation
    iex> Accent.Scopes.Translation.parse_empty(Accent.Translation, true)
    #Ecto.Query<from t0 in Accent.Translation, where: t0.value_type in ^["empty", "null"]>
  """
  @spec parse_empty(Queryable.t(), nil | boolean()) :: Queryable.t()
  def parse_empty(query, nil), do: query
  def parse_empty(query, true), do: from(translations in query, where: translations.value_type in ^["empty", "null"])

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

  @spec parse_added_last_sync(Queryable.t(), nil | boolean(), String.t()) :: Queryable.t()
  def parse_added_last_sync(query, nil, _), do: query

  def parse_added_last_sync(query, true, project_id) do
    from(
      operations in Operation,
      where: operations.project_id == ^project_id,
      where: operations.action == ^"sync",
      select: operations.id,
      limit: 1,
      order_by: [desc: operations.inserted_at]
    )
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
  @spec from_revision(Queryable.t(), String.t()) :: Queryable.t()
  def from_revision(query, revision_id), do: from(query, where: [revision_id: ^revision_id])

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
    #Ecto.Query<from t0 in Accent.Translation, where: ilike(t0.key, ^\"%test%\") or ilike(t0.corrected_text, ^\"%test%\")>
    iex> Accent.Scopes.Translation.from_search(Accent.Translation, "030519c4-1d47-42bb-95ee-205880be01d9")
    #Ecto.Query<from t0 in Accent.Translation, where: ilike(t0.key, ^\"%030519c4-1d47-42bb-95ee-205880be01d9%\") or ilike(t0.corrected_text, ^\"%030519c4-1d47-42bb-95ee-205880be01d9%\"), or_where: t0.id == ^\"030519c4-1d47-42bb-95ee-205880be01d9\">
  """
  @spec from_search(Queryable.t(), any()) :: Queryable.t()
  def from_search(query, nil), do: query
  def from_search(query, term) when term === "", do: query
  def from_search(query, term) when not is_binary(term), do: query

  def from_search(query, search_term) do
    term = "%" <> search_term <> "%"

    from(
      translation in query,
      where: ilike(translation.key, ^term) or ilike(translation.corrected_text, ^term)
    )
    |> from_search_id(search_term)
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
