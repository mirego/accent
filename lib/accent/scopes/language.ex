defmodule Accent.Scopes.Language do
  import Ecto.Query, only: [from: 2]

  @doc """
  ## Examples

    iex> Accent.Scopes.Language.from_search(Accent.Language, "")
    Accent.Language
    iex> Accent.Scopes.Language.from_search(Accent.Language, nil)
    Accent.Language
    iex> Accent.Scopes.Language.from_search(Accent.Language, 1234)
    Accent.Language
    iex> Accent.Scopes.Language.from_search(Accent.Language, "test")
    #Ecto.Query<from l in Accent.Language, where: ilike(l.name, ^"%test%")>
  """
  @spec from_search(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def from_search(query, nil), do: query
  def from_search(query, term) when term === "", do: query
  def from_search(query, term) when not is_binary(term), do: query

  def from_search(query, term) do
    term = "%" <> term <> "%"

    from(l in query, where: ilike(l.name, ^term))
  end
end
