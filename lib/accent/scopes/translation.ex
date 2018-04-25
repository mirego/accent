defmodule Accent.Scopes.Translation do
  import Ecto.Query

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.not_id(Accent.Translation, "test")
    #Ecto.Query<from t in Accent.Translation, where: t.id != ^"test">
  """
  @spec not_id(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def not_id(query, id) do
    from(t in query, where: t.id != ^id)
  end

  @doc """
  Default ordering is by ascending key

  ## Examples

    iex> Accent.Scopes.Translation.parse_order(Accent.Translation, nil)
    #Ecto.Query<from t in Accent.Translation, order_by: [asc: t.key]>
    iex> Accent.Scopes.Translation.parse_order(Accent.Translation, "key")
    #Ecto.Query<from t in Accent.Translation, order_by: [asc: t.key]>
    iex> Accent.Scopes.Translation.parse_order(Accent.Translation, "-key")
    #Ecto.Query<from t in Accent.Translation, order_by: [desc: t.key]>
    iex> Accent.Scopes.Translation.parse_order(Accent.Translation, "updated")
    #Ecto.Query<from t in Accent.Translation, order_by: [asc: t.updated_at]>
    iex> Accent.Scopes.Translation.parse_order(Accent.Translation, "-updated")
    #Ecto.Query<from t in Accent.Translation, order_by: [desc: t.updated_at]>
    iex> Accent.Scopes.Translation.parse_order(Accent.Translation, "index")
    #Ecto.Query<from t in Accent.Translation, order_by: [asc: t.file_index]>
    iex> Accent.Scopes.Translation.parse_order(Accent.Translation, "-index")
    #Ecto.Query<from t in Accent.Translation, order_by: [desc: t.file_index]>
  """
  @spec parse_order(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def parse_order(query, "index"), do: from(t in query, order_by: [asc: :file_index])
  def parse_order(query, "-index"), do: from(t in query, order_by: [desc: :file_index])
  def parse_order(query, "key"), do: from(t in query, order_by: [asc: :key])
  def parse_order(query, "-key"), do: from(t in query, order_by: [desc: :key])
  def parse_order(query, "updated"), do: from(t in query, order_by: [asc: :updated_at])
  def parse_order(query, "-updated"), do: from(t in query, order_by: [desc: :updated_at])
  def parse_order(query, _), do: from(t in query, order_by: [asc: :key])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.active(Accent.Translation)
    #Ecto.Query<from t in Accent.Translation, where: t.removed == false>
  """
  @spec active(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def active(query), do: from(t in query, where: [removed: false])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.not_locked(Accent.Translation)
    #Ecto.Query<from t in Accent.Translation, where: t.locked == false>
  """
  @spec not_locked(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def not_locked(query), do: from(t in query, where: [locked: false])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.parse_conflicted(Accent.Translation, nil)
    Accent.Translation
    iex> Accent.Scopes.Translation.parse_conflicted(Accent.Translation, false)
    #Ecto.Query<from t in Accent.Translation, where: t.conflicted == false>
    iex> Accent.Scopes.Translation.parse_conflicted(Accent.Translation, true)
    #Ecto.Query<from t in Accent.Translation, where: t.conflicted == true>
  """
  @spec parse_conflicted(Ecto.Queryable.t(), nil | boolean()) :: Ecto.Queryable.t()
  def parse_conflicted(query, nil), do: query
  def parse_conflicted(query, false), do: not_conflicted(query)
  def parse_conflicted(query, true), do: conflicted(query)

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.conflicted(Accent.Translation)
    #Ecto.Query<from t in Accent.Translation, where: t.conflicted == true>
  """
  @spec conflicted(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def conflicted(query), do: from(t in query, where: [conflicted: true])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.not_conflicted(Accent.Translation)
    #Ecto.Query<from t in Accent.Translation, where: t.conflicted == false>
  """
  @spec not_conflicted(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def not_conflicted(query), do: from(t in query, where: [conflicted: false])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.no_version(Accent.Translation)
    #Ecto.Query<from t in Accent.Translation, where: is_nil(t.version_id)>
  """
  @spec no_version(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def no_version(query), do: from_version(query, nil)

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_version(Accent.Translation, nil)
    #Ecto.Query<from t in Accent.Translation, where: is_nil(t.version_id)>
    iex> Accent.Scopes.Translation.from_version(Accent.Translation, "test")
    #Ecto.Query<from t in Accent.Translation, where: t.version_id == ^"test">
  """
  @spec from_version(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def from_version(query, nil), do: from(t in query, where: is_nil(t.version_id))
  def from_version(query, version_id), do: from(t in query, where: [version_id: ^version_id])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_revision(Accent.Translation, "test")
    #Ecto.Query<from t in Accent.Translation, where: t.revision_id == ^"test">
  """
  @spec from_revision(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def from_revision(query, revision_id), do: from(t in query, where: [revision_id: ^revision_id])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_revisions(Accent.Translation, ["test"])
    #Ecto.Query<from t in Accent.Translation, where: t.revision_id in ^["test"]>
  """
  @spec from_revision(Ecto.Queryable.t(), list(String.t())) :: Ecto.Queryable.t()
  def from_revisions(query, revision_ids), do: from(t in query, where: t.revision_id in ^revision_ids)

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_project(Accent.Translation, "test")
    #Ecto.Query<from t in Accent.Translation, left_join: p in assoc(t, :project), where: p.id == ^"test">
  """
  @spec from_project(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def from_project(query, project_id) do
    from(
      translation in query,
      left_join: project in assoc(translation, :project),
      where: project.id == ^project_id
    )
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_document(Accent.Translation, nil)
    #Ecto.Query<from t in Accent.Translation, where: is_nil(t.document_id)>
    iex> Accent.Scopes.Translation.from_document(Accent.Translation, :all)
    Accent.Translation
    iex> Accent.Scopes.Translation.from_document(Accent.Translation, "test")
    #Ecto.Query<from t in Accent.Translation, where: t.document_id == ^"test">
  """
  @spec from_document(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def from_document(query, nil), do: from(t in query, where: is_nil(t.document_id))
  def from_document(query, :all), do: query
  def from_document(query, document_id), do: from(t in query, where: [document_id: ^document_id])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_documents(Accent.Translation, ["test"])
    #Ecto.Query<from t in Accent.Translation, where: t.document_id in ^["test"]>
  """
  @spec from_documents(Ecto.Queryable.t(), list(String.t())) :: Ecto.Queryable.t()
  def from_documents(query, document_ids), do: from(t in query, where: t.document_id in ^document_ids)

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_key(Accent.Translation, "test")
    #Ecto.Query<from t in Accent.Translation, where: t.key == ^"test">
  """
  @spec from_key(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def from_key(query, key), do: from(t in query, where: [key: ^key])

  @doc """
  ## Examples

    iex> Accent.Scopes.Translation.from_keys(Accent.Translation, ["test"])
    #Ecto.Query<from t in Accent.Translation, where: t.key in ^["test"]>
  """
  @spec from_keys(Ecto.Queryable.t(), list(String.t())) :: Ecto.Queryable.t()
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
    #Ecto.Query<from t in Accent.Translation, where: ilike(t.key, ^\"%test%\") or ilike(t.corrected_text, ^\"%test%\")>
    iex> Accent.Scopes.Translation.from_search(Accent.Translation, "030519c4-1d47-42bb-95ee-205880be01d9")
    #Ecto.Query<from t in Accent.Translation, where: ilike(t.key, ^\"%030519c4-1d47-42bb-95ee-205880be01d9%\") or ilike(t.corrected_text, ^\"%030519c4-1d47-42bb-95ee-205880be01d9%\"), or_where: t.id == ^\"030519c4-1d47-42bb-95ee-205880be01d9\">
  """
  @spec from_search(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
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
    #Ecto.Query<from t in Accent.Translation, select: %{id: t.id, key: t.key, updated_at: t.updated_at, corrected_text: t.corrected_text}>
  """
  @spec select_key_text(Ecto.Queryable.t()) :: Ecto.Queryable.t()
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
