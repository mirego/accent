defmodule Accent.Repo.Migrations.AddLanguageOverrideInRevisions do
  use Ecto.Migration

  def change do
    alter table(:revisions) do
      add(:name, :string)
      add(:slug, :string)
      add(:iso_639_1, :string)
      add(:iso_639_3, :string)
      add(:locale, :string)
      add(:android_code, :string)
      add(:osx_code, :string)
      add(:osx_locale, :string)
      add(:plural_forms, :string)
    end
  end
end
