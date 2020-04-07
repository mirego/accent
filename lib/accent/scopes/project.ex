defmodule Accent.Scopes.Project do
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
    #Ecto.Query<from p0 in Accent.Project, where: ilike(p0.name, ^"%test%")>
  """
  @spec from_search(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def from_search(query, term) do
    Accent.Scopes.Search.from_search(query, term, :name)
  end

  @doc """
  Fill `translations_count`, `conflicts_count` and `reviewed_count` for projects.
  """
  @spec with_stats(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def with_stats(query) do
    translations =
      from(
        t in Accent.Translation,
        inner_join: revisions in assoc(t, :revision),
        select: %{field_id: revisions.project_id, count: count(t)},
        where: [removed: false, locked: false],
        where: is_nil(t.version_id),
        group_by: revisions.project_id
      )

    reviewed = from(translations, where: [conflicted: false])

    from(
      projects in query,
      left_join: translations in subquery(translations),
      on: translations.field_id == projects.id,
      left_join: reviewed in subquery(reviewed),
      on: reviewed.field_id == projects.id,
      select_merge: %{
        translations_count: coalesce(translations.count, 0),
        reviewed_count: coalesce(reviewed.count, 0),
        conflicts_count: coalesce(translations.count, 0) - coalesce(reviewed.count, 0)
      }
    )
  end
end
