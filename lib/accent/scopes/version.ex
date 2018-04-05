defmodule Accent.Scopes.Version do
  import Ecto.Query, only: [from: 2]

  @doc """
  ## Examples

    iex> Accent.Scopes.Version.from_project(Accent.Version, "test")
    #Ecto.Query<from v in Accent.Version, where: v.project_id == ^"test">
    iex> Accent.Scopes.Version.from_project(Accent.Version, nil)
    Accent.Version
  """
  @spec from_project(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def from_project(query, nil), do: query

  def from_project(query, project_id) do
    from(v in query, where: [project_id: ^project_id])
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Version.from_tag(Accent.Version, "test")
    #Ecto.Query<from v in Accent.Version, where: v.tag == ^"test">
    iex> Accent.Scopes.Version.from_tag(Accent.Version, nil)
    Accent.Version
  """
  @spec from_tag(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def from_tag(query, nil), do: query

  def from_tag(query, tag) do
    from(v in query, where: [tag: ^tag])
  end
end
