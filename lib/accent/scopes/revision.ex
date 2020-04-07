defmodule Accent.Scopes.Revision do
  import Ecto.Query, only: [from: 2]

  @doc """
  ## Examples

    iex> Accent.Scopes.Revision.from_project(Accent.Revision, "test")
    #Ecto.Query<from r0 in Accent.Revision, join: l1 in assoc(r0, :language), where: r0.project_id == ^\"test\", order_by: [desc: r0.master, asc: l1.name]>
  """
  @spec from_project(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def from_project(query, project_id) do
    from(
      revision in query,
      where: [project_id: ^project_id],
      inner_join: language in assoc(revision, :language),
      order_by: [desc: revision.master, asc: language.name]
    )
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Revision.from_language(Accent.Revision, "test")
    #Ecto.Query<from r0 in Accent.Revision, where: r0.language_id == ^\"test\">
  """
  @spec from_language(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def from_language(query, language_id) do
    from(r in query, where: [language_id: ^language_id])
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Revision.from_language_slug(Accent.Revision, "en-US")
    #Ecto.Query<from r0 in Accent.Revision, join: l1 in assoc(r0, :language), where: l1.slug == ^\"en-US\">
  """
  @spec from_language_slug(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def from_language_slug(query, language_slug) do
    from(r in query, join: l in assoc(r, :language), where: l.slug == ^language_slug)
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Revision.master(Accent.Revision)
    #Ecto.Query<from r0 in Accent.Revision, where: r0.master == true>
  """
  @spec master(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def master(query) do
    from(r in query, where: [master: true])
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Revision.slaves(Accent.Revision)
    #Ecto.Query<from r0 in Accent.Revision, where: r0.master == false>
  """
  @spec slaves(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def slaves(query) do
    from(r in query, where: [master: false])
  end

  @doc """
  Fill `translations_count`, `conflicts_count` and `reviewed_count` for revisions.
  """
  @spec with_stats(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def with_stats(query) do
    Accent.Scopes.TranslationsCount.with_stats(query, :revision_id)
  end
end
