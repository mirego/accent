require Ecto.Query

timestamps = %{
  inserted_at: DateTime.utc_now(),
  updated_at: DateTime.utc_now()
}

languages =
  "priv/repo/languages.json"
  |> File.read!()
  |> Poison.decode!(keys: :atoms!)
  |> Enum.map(&Map.merge(&1, timestamps))

Accent.Repo.insert_all(Accent.Language, languages, on_conflict: :nothing, conflict_target: :slug)

"priv/repo/languages-plural-forms.json"
|> File.read!()
|> Poison.decode!(keys: :atoms!)
|> Enum.map(fn %{locale: locale, plural_forms: plural_forms} ->
  language = Ecto.Query.from(Accent.Language, where: [iso_639_1: ^locale])
  Accent.Repo.update_all(language, set: [plural_forms: plural_forms])
end)
