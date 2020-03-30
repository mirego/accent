defmodule Accent.Scopes.TranslationsCount do
  import Ecto.Query

  def with_stats(query, column, options \\ []) do
    exclude_empty_translations = Keyword.get(options, :exclude_empty_translations, false)

    translations =
      from(
        t in Accent.Translation,
        select: %{field_id: field(t, ^column), count: count(t)},
        where: [removed: false, locked: false],
        where: is_nil(t.version_id),
        group_by: field(t, ^column)
      )

    query =
      query
      |> count_translations(translations, exclude_empty_translations)
      |> count_reviewed(translations)

    from(
      [translations: t, reviewed: r] in query,
      select_merge: %{
        translations_count: coalesce(t.count, 0),
        reviewed_count: coalesce(r.count, 0),
        conflicts_count: coalesce(t.count, 0) - coalesce(r.count, 0)
      }
    )
  end

  defp count_translations(query, translations, _exclude_empty_translations = true) do
    from(q in query, inner_join: translations in subquery(translations), as: :translations, on: translations.field_id == q.id)
  end

  defp count_translations(query, translations, _exclude_empty_translations = false) do
    from(q in query, left_join: translations in subquery(translations), as: :translations, on: translations.field_id == q.id)
  end

  defp count_reviewed(query, translations) do
    reviewed = from(translations, where: [conflicted: false])
    from(q in query, left_join: translations in subquery(reviewed), as: :reviewed, on: translations.field_id == q.id)
  end
end
