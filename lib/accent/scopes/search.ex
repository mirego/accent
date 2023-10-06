defmodule Accent.Scopes.Search do
  @moduledoc false
  import Ecto.Query, only: [from: 2, dynamic: 2]

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
  @spec from_search(Ecto.Queryable.t(), any(), atom() | list(atom())) :: Ecto.Queryable.t()
  def from_search(query, nil, _), do: query
  def from_search(query, term, _) when term === "", do: query
  def from_search(query, term, _) when not is_binary(term), do: query

  def from_search(query, term, fields) do
    term = "%" <> term <> "%"

    conditions =
      Enum.reduce(List.wrap(fields), false, fn field, conditions ->
        dynamic([q], ilike(field(q, ^field), ^term) or ^conditions)
      end)

    from(query, where: ^conditions)
  end
end
