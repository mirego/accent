defmodule Accent.Scopes.ProjectLintEntry do
  @moduledoc false
  import Ecto.Query, only: [from: 2]

  @spec default_order(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def default_order(query) do
    from(query, order_by: [desc: :inserted_at])
  end

  @spec from_project(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def from_project(query, project_id) do
    from(entry in query, where: entry.project_id == ^project_id, order_by: [desc: entry.inserted_at], select: entry)
  end
end
