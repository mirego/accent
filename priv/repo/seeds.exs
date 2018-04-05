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
