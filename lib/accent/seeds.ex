defmodule Accent.Seeds do
  import Ecto.Query

  defmodule Language do
    use Accent.Schema

    schema "languages" do
      field(:name, :string)
      field(:slug, :string)

      field(:iso_639_1, :string)
      field(:iso_639_3, :string)
      field(:locale, :string)
      field(:android_code, :string)
      field(:osx_code, :string)
      field(:osx_locale, :string)
      field(:plural_forms, :string)

      timestamps()
    end
  end

  def run(repo) do
    timestamps = %{
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }

    "languages.json"
    |> fetch()
    |> Enum.map(&Map.merge(&1, timestamps))
    |> (&repo.insert_all(Language, &1, on_conflict: :nothing, conflict_target: :slug)).()

    "languages-plural-forms.json"
    |> fetch()
    |> Enum.each(fn %{locale: locale, plural_forms: plural_forms} ->
      language = from(Language, where: [iso_639_1: ^locale])
      repo.update_all(language, set: [plural_forms: plural_forms])
    end)

    :ok
  end

  defp fetch(filename) do
    path = "#{:code.priv_dir(:accent)}/repo/#{filename}"

    path
    |> File.read!()
    |> Jason.decode!(keys: :atoms)
  end
end
