defmodule Accent.Language do
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

    timestamps()
  end
end
