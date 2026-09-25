defmodule Accent.Scopes.TranslationsCount do
  @moduledoc false
  import Ecto.Query

  def with_stats(query, column, options \\ []) do
    if Keyword.get(options, :skip_stats, false) do
      from(q in query,
        select_merge: %{
          translations_count: 0,
          translated_count: 0,
          reviewed_count: 0,
          conflicts_count: 0
        }
      )
    else
      do_with_stats(query, column, options)
    end
  end

  defp do_with_stats(query, column, options) do
    exclude_empty_translations = Keyword.get(options, :exclude_empty_translations, false)
    version_id = Keyword.get(options, :version_id, nil)
    document_id = Keyword.get(options, :document_id, nil)

    stats_subquery =
      from(t in Accent.Translation,
        select: %{
          total_count: count(t),
          reviewed_count: filter(count(t), not t.conflicted),
          translated_count: filter(count(t), t.translated)
        },
        where: field(t, ^column) == parent_as(:stats_parent).id,
        where: [removed: false, locked: false]
      )

    stats_subquery =
      if version_id do
        from(t in stats_subquery,
          inner_join: versions in assoc(t, :version),
          where: versions.tag == ^version_id or versions.id == ^version_id
        )
      else
        from(t in stats_subquery, where: is_nil(t.version_id))
      end

    stats_subquery =
      if document_id do
        from(t in stats_subquery, where: t.document_id == ^document_id)
      else
        stats_subquery
      end

    query =
      from(q in query,
        as: :stats_parent,
        inner_lateral_join: stats in subquery(stats_subquery),
        as: :stats,
        on: true
      )

    query =
      if exclude_empty_translations do
        from([stats: s] in query, where: s.total_count > 0)
      else
        query
      end

    from([stats: s] in query,
      select_merge: %{
        translations_count: s.total_count,
        translated_count: s.translated_count,
        reviewed_count: s.reviewed_count,
        conflicts_count: s.total_count - s.reviewed_count
      }
    )
  end
end
