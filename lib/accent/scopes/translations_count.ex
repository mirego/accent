defmodule Accent.Scopes.TranslationsCount do
  @moduledoc false
  import Ecto.Query

  def with_stats(query, column, options \\ []) do
    exclude_empty_translations = Keyword.get(options, :exclude_empty_translations, false)
    version_id = Keyword.get(options, :version_id, nil)

    translations =
      from(
        t in Accent.Translation,
        select: %{field_id: field(t, ^column), count: count(t)},
        where: [removed: false, locked: false],
        group_by: field(t, ^column)
      )

    translations =
      if version_id do
        from(t in translations,
          inner_join: versions in assoc(t, :version),
          where: versions.tag == ^version_id
        )
      else
        from(t in translations, where: is_nil(t.version_id))
      end

    query =
      query
      |> count_translations(translations, exclude_empty_translations)
      |> count_reviewed(translations)
      |> count_translated(translations)

    from(
      [translations: t, reviewed: r, translated: td] in query,
      select_merge: %{
        translations_count: coalesce(t.count, 0),
        translated_count: coalesce(td.count, 0),
        reviewed_count: coalesce(r.count, 0),
        conflicts_count: coalesce(t.count, 0) - coalesce(r.count, 0)
      }
    )
  end

  defp count_translations(query, translations, true = _exclude_empty_translations) do
    from(q in query,
      inner_join: translations in subquery(translations),
      as: :translations,
      on: translations.field_id == q.id
    )
  end

  defp count_translations(query, translations, false = _exclude_empty_translations) do
    from(q in query,
      left_join: translations in subquery(translations),
      as: :translations,
      on: translations.field_id == q.id
    )
  end

  defp count_reviewed(query, translations) do
    reviewed = from(translations, where: [conflicted: false])
    from(q in query, left_join: translations in subquery(reviewed), as: :reviewed, on: translations.field_id == q.id)
  end

  defp count_translated(query, translations) do
    translated = from(translations, where: [translated: true])

    from(q in query,
      left_join: translations in subquery(translated),
      as: :translated,
      on: translations.field_id == q.id
    )
  end
end
