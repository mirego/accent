defmodule Accent.Scopes.Language do
  @doc """
  ## Examples

    iex> Accent.Scopes.Language.from_search(Accent.Language, "")
    Accent.Language
    iex> Accent.Scopes.Language.from_search(Accent.Language, nil)
    Accent.Language
    iex> Accent.Scopes.Language.from_search(Accent.Language, 1234)
    Accent.Language
    iex> Accent.Scopes.Language.from_search(Accent.Language, "test")
    #Ecto.Query<from l0 in Accent.Language, where: ilike(l0.name, ^"%test%")>
  """
  @spec from_search(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def from_search(query, term) do
    Accent.Scopes.Search.from_search(query, term, :name)
  end
end
