defmodule Accent.Scopes.Document do
  import Ecto.Query, only: [from: 2]

  @doc """
  ## Examples

    iex> Accent.Scopes.Document.from_project(Accent.Document, "test")
    #Ecto.Query<from d0 in Accent.Document, where: d0.project_id == ^\"test\">
  """
  @spec from_project(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def from_project(query, project_id) do
    from(query, where: [project_id: ^project_id])
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Document.from_path(Accent.Document, "test")
    #Ecto.Query<from d0 in Accent.Document, where: d0.path == ^\"test\">
  """
  @spec from_path(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def from_path(query, path) do
    from(query, where: [path: ^path])
  end

  @doc """
  Fill `translations_count`, `conflicts_count` and `reviewed_count` for documents.
  """
  @spec with_stats(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def with_stats(query) do
    Accent.Scopes.TranslationsCount.with_stats(query, :document_id, exclude_empty_translations: true)
  end
end
