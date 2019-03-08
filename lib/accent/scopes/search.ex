defmodule Accent.Scopes.Search do
  import Ecto.Query, only: [from: 2]

  @doc """
  ## Examples

    iex> Accent.Scopes.Search.from_search(Accent.Project, "", :name)
    Accent.ProjectSearch
    iex> Accent.Scopes.Search.from_search(Accent.Project, nil, :name)
    Accent.ProjectSearch
    iex> Accent.Scopes.Search.from_search(Accent.Project, 1234, :name)
    Accent.ProjectSearch
    iex> Accent.Scopes.Search.from_search(Accent.Project, "test", :name)
    #Ecto.Query<from p0 in Accent.Project, where: ilike(p0.name, ^"%test%")>
  """
  @spec from_search(Ecto.Queryable.t(), any(), atom()) :: Ecto.Queryable.t()
  def from_search(query, nil, _), do: query
  def from_search(query, term, _) when term === "", do: query
  def from_search(query, term, _) when not is_binary(term), do: query

  def from_search(query, term, field) do
    term = "%" <> term <> "%"

    from(q in query, where: ilike(field(q, ^field), ^term))
  end
end
