require Ecto.Query

timestamps = %{
  inserted_at: DateTime.utc_now(),
  updated_at: DateTime.utc_now()
}

defmodule JSONFile do
  def fetch(filename) do
    :accent
    |> Application.app_dir("priv/repo/" <> filename)
    |> File.read!()
    |> Jason.decode!(keys: :atoms!)
  end
end

"languages.json"
|> JSONFile.fetch()
|> Enum.map(&Map.merge(&1, timestamps))
|> (&Accent.Repo.insert_all(Accent.Language, &1, on_conflict: :nothing, conflict_target: :slug)).()

"languages-plural-forms.json"
|> JSONFile.fetch()
|> Enum.map(fn %{locale: locale, plural_forms: plural_forms} ->
  language = Ecto.Query.from(Accent.Language, where: [iso_639_1: ^locale])
  Accent.Repo.update_all(language, set: [plural_forms: plural_forms])
end)
