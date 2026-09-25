defmodule Accent.Scopes.Project do
  @moduledoc false
  import Ecto.Query

  @doc """
  ## Examples

    iex> Accent.Scopes.Project.from_search(Accent.Project, "")
    Accent.Project
    iex> Accent.Scopes.Project.from_search(Accent.Project, nil)
    Accent.Project
    iex> Accent.Scopes.Project.from_search(Accent.Project, 1234)
    Accent.Project
    iex> Accent.Scopes.Project.from_search(Accent.Project, "test")
    #Ecto.Query<from p0 in Accent.Project, where: ilike(p0.name, ^"%test%") or ^false>
  """
  @spec from_search(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def from_search(query, term) do
    Accent.Scopes.Search.from_search(query, term, :name)
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Project.from_ids(Accent.Project, nil)
    Accent.Project
    iex> Accent.Scopes.Project.from_ids(Accent.Project, ["not-uuid", "08895faf-eb7e-48cc-8cd0-4175a6f39464"])
    #Ecto.Query<from p0 in Accent.Project, where: p0.id in ^["08895faf-eb7e-48cc-8cd0-4175a6f39464"]>
  """
  @spec from_ids(Ecto.Queryable.t(), [String.t()] | nil) :: Ecto.Queryable.t()
  def from_ids(query, nil), do: query

  def from_ids(query, ids) do
    ids = Enum.filter(ids, &(Ecto.UUID.cast(&1) !== :error))

    from(p in query, where: p.id in ^ids)
  end

  @doc """
  Fill `translations_count`, `conflicts_count`, `translated_count` and `reviewed_count` for projects.
  """
  @spec with_stats(Ecto.Queryable.t(), Keyword.t()) :: Ecto.Queryable.t()
  def with_stats(query, options \\ []) do
    if Keyword.get(options, :skip_stats, false) do
      from(q in query,
        select_merge: %{
          translations_count: 0,
          translated_count: 0,
          reviewed_count: 0,
          conflicts_count: 0
        }
      )
    else
      do_with_stats(query)
    end
  end

  defp do_with_stats(query) do
    project_ids =
      query
      |> exclude(:order_by)
      |> exclude(:preload)
      |> exclude(:select)
      |> exclude(:limit)
      |> exclude(:offset)
      |> select([p], p.id)

    stats =
      from(
        t in Accent.Translation,
        inner_join: revisions in assoc(t, :revision),
        select: %{
          field_id: revisions.project_id,
          total_count: count(t),
          reviewed_count: filter(count(t), not t.conflicted),
          translated_count: filter(count(t), t.translated)
        },
        where: [removed: false, locked: false],
        where: is_nil(t.version_id),
        where: revisions.project_id in subquery(project_ids),
        group_by: revisions.project_id
      )

    from(
      projects in query,
      left_join: stats in subquery(stats),
      on: stats.field_id == projects.id,
      select_merge: %{
        translations_count: coalesce(stats.total_count, 0),
        translated_count: coalesce(stats.translated_count, 0),
        reviewed_count: coalesce(stats.reviewed_count, 0),
        conflicts_count: coalesce(stats.total_count, 0) - coalesce(stats.reviewed_count, 0)
      }
    )
  end
end
