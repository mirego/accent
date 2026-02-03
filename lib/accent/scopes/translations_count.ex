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

    # Single subquery with conditional aggregates - scans table once instead of three times
    stats_subquery =
      from(t in Accent.Translation,
        select: %{
          field_id: field(t, ^column),
          total_count: count(t),
          reviewed_count: filter(count(t), not t.conflicted),
          translated_count: filter(count(t), t.translated)
        },
        where: [removed: false, locked: false],
        group_by: field(t, ^column)
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

    query = join_stats(query, stats_subquery, exclude_empty_translations)

    from([stats: s] in query,
      select_merge: %{
        translations_count: coalesce(s.total_count, 0),
        translated_count: coalesce(s.translated_count, 0),
        reviewed_count: coalesce(s.reviewed_count, 0),
        conflicts_count: coalesce(s.total_count, 0) - coalesce(s.reviewed_count, 0)
      }
    )
  end

  defp join_stats(query, stats_subquery, true = _exclude_empty_translations) do
    from(q in query,
      inner_join: stats in subquery(stats_subquery),
      as: :stats,
      on: stats.field_id == q.id
    )
  end

  defp join_stats(query, stats_subquery, false = _exclude_empty_translations) do
    from(q in query,
      left_join: stats in subquery(stats_subquery),
      as: :stats,
      on: stats.field_id == q.id
    )
  end
end
