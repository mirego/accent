defmodule Accent.Scopes.Language do
  @moduledoc false
  import Ecto.Query, only: [from: 2]

  alias Accent.Revision

  require Accent.Scopes.PopularLanguagesFragment

  @doc """
  Either search by a query or fallback to all languages with the most used at the top.
  """
  @spec from_search(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def from_search(query, nil), do: default_order_by(query)
  def from_search(query, ""), do: default_order_by(query)

  def from_search(query, term) do
    search = Accent.Scopes.Search.from_search(query, term, [:name, :slug])

    from(
      languages in search,
      order_by: [
        desc: languages.slug == ^term,
        desc: ilike(languages.slug, ^"#{term}%"),
        asc: fragment("character_length(?)", languages.slug)
      ]
    )
  end

  defp default_order_by(query) do
    priorities_query =
      from(revisions in Revision,
        join: languages in assoc(revisions, :language),
        group_by: languages.slug,
        select: %{
          slug: languages.slug,
          index: over(row_number(), order_by: [desc: count()])
        },
        limit: 5
      )

    from(languages in query,
      left_join: priorities in subquery(priorities_query),
      on: priorities.slug == languages.slug,
      order_by: [
        asc: fragment("CASE WHEN ? IS NULL THEN 999 ELSE ? END", priorities.index, priorities.index),
        asc: languages.name
      ]
    )
  end
end
