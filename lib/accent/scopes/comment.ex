defmodule Accent.Scopes.Comment do
  import Ecto.Query, only: [from: 2]

  @doc """
  ## Examples

    iex> Accent.Scopes.Comment.default_order(Accent.Comment)
    #Ecto.Query<from c0 in Accent.Comment, order_by: [desc: c0.inserted_at]>
  """
  @spec default_order(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def default_order(query) do
    from(query, order_by: [desc: :inserted_at])
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Comment.from_project(Accent.Comment, "test")
    #Ecto.Query<from c0 in Accent.Comment, join: t1 in assoc(c0, :translation), join: r2 in assoc(t1, :revision), join: p3 in assoc(r2, :project), where: p3.id == ^\"test\", order_by: [desc: c0.inserted_at], select: c0>
  """
  @spec from_project(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def from_project(query, project_id) do
    from(
      comment in query,
      inner_join: translation in assoc(comment, :translation),
      inner_join: revision in assoc(translation, :revision),
      inner_join: project in assoc(revision, :project),
      where: project.id == ^project_id,
      order_by: [desc: comment.inserted_at],
      select: comment
    )
  end
end
