defmodule Accent.Repo.Migrations.AddLocalesColumnsOnLanguages do
  use Ecto.Migration

  def change do
    alter table(:languages) do
      add :iso_639_1, :string
      add :iso_639_3, :string
      add :locale, :string
      add :android_code, :string
      add :osx_code, :string
      add :osx_locale, :string
    end

    create index(:languages, [:slug], unique: true)
  end
end
