defmodule Accent.Scopes.Project do
  import Ecto.Query, only: [from: 2]

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
  def from_search(query, nil), do: query
  def from_search(query, term) when term === "", do: query
  def from_search(query, term) when not is_binary(term), do: query

  def from_search(query, term) do
    term = "%" <> term <> "%"

    from(p in query, where: ilike(p.name, ^term))
  end
end
