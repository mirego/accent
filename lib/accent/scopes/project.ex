defmodule Accent.Scopes.Project do
  @doc """
  ## Examples

    iex> Accent.Scopes.Project.from_search(Accent.Project, "")
    Accent.Project
    iex> Accent.Scopes.Project.from_search(Accent.Project, nil)
    Accent.Project
    iex> Accent.Scopes.Project.from_search(Accent.Project, 1234)
    Accent.Project
    iex> Accent.Scopes.Project.from_search(Accent.Project, "test")
    #Ecto.Query<from p in Accent.Project, where: ilike(p.name, ^"%test%")>
  """
  @spec from_search(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def from_search(query, term) do
    Accent.Scopes.Search.from_search(query, term, :name)
  end
end
