defmodule Accent.Scopes.Integration do
  import Ecto.Query, only: [from: 2]

  @doc """
  ## Examples

    iex> Accent.Scopes.Integration.from_project(Accent.Integration, "test")
    #Ecto.Query<from i0 in Accent.Integration, where: i0.project_id == ^\"test\">
  """
  @spec from_project(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def from_project(query, project_id) do
    from(query, where: [project_id: ^project_id])
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Integration.from_service(Accent.Integration, "test")
    #Ecto.Query<from i0 in Accent.Integration, where: i0.service == ^\"test\">
  """
  @spec from_service(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def from_service(query, service) do
    from(query, where: [service: ^service])
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Integration.from_data_repository(Accent.Integration, "test")
    #Ecto.Query<from i0 in Accent.Integration, where: fragment(\"?->>'repository' = ?\", i0.data, ^\"test\")>
  """
  @spec from_data_repository(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def from_data_repository(query, repository) do
    from(i in query, where: fragment("?->>'repository' = ?", i.data, ^repository))
  end
end
