defmodule Accent.Scopes.Version do
  import Ecto.Query, only: [from: 2]

  alias Accent.Repo

  @doc """
  ## Examples

    iex> Accent.Scopes.Version.from_project(Accent.Version, "test")
    #Ecto.Query<from v0 in Accent.Version, where: v0.project_id == ^"test">
    iex> Accent.Scopes.Version.from_project(Accent.Version, nil)
    Accent.Version
  """
  @spec from_project(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def from_project(query, nil), do: query

  def from_project(query, project_id) do
    from(query, where: [project_id: ^project_id])
  end

  @doc """
  Tag can either be an exact tag or a valid requirement parsed by the Version module included
  in the standard library. If no exact matches are found, the requirement is compared to each versions
  scoped in the queryable.

  ## Examples

    iex> Accent.Scopes.Version.from_tag(Accent.Version, "test")
    #Ecto.Query<from v0 in Accent.Version, where: v0.tag == ^"test">
    iex> Accent.Scopes.Version.from_tag(Accent.Version, nil)
    Accent.Version
  """
  @spec from_tag(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def from_tag(query, nil), do: query

  def from_tag(query, tag) do
    exact_filter_query = from(query, where: [tag: ^tag])

    cond do
      Repo.exists?(exact_filter_query) ->
        exact_filter_query

      Version.parse_requirement(tag) !== :error ->
        from_requirement_version(query, tag)

      true ->
        exact_filter_query
    end
  end

  defp from_requirement_version(query, requirement_version) do
    query
    |> from(select: [:tag])
    |> Repo.all()
    |> Enum.map(&Accent.Version.with_parsed_tag/1)
    |> Enum.reject(&(&1.parsed_tag === :error))
    |> Enum.sort_by(& &1.parsed_tag, &(Version.compare(&1, &2) === :gt))
    |> Enum.find(&Version.match?(&1.parsed_tag, requirement_version))
    |> case do
      nil -> from(query, where: [tag: ^requirement_version])
      %{tag: tag} -> from(query, where: [tag: ^tag])
    end
  end
end
