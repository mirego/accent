defmodule Accent.Scopes.Comment do
  import Ecto.Query, only: [from: 2]

  @doc """
  ## Examples

    iex> Accent.Scopes.Comment.default_order(Accent.Comment)
    #Ecto.Query<from c in Accent.Comment, order_by: [desc: c.inserted_at]>
  """
  @spec default_order(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def default_order(query) do
    from(c in query, order_by: [desc: :inserted_at])
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Comment.from_project(Accent.Comment, "test")
    #Ecto.Query<from c in Accent.Comment, join: t in assoc(c, :translation), join: r in assoc(t, :revision), join: p in assoc(r, :project), where: p.id == ^\"test\", order_by: [desc: c.inserted_at], select: c>
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
