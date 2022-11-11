defmodule Accent.Repo.Migrations.AddRtlOnLanguages do
  use Ecto.Migration

  @rtl_languages ~w(
    ar
    ar-BH
    ar-EG
    ar-SA
    ar-YE
    he
    dv
    syc
    ur-IN
    fa
    ks
    ks-PK
    ms
    ku
    kmr
    pa-IN
    pa-PK
    sd
    bal
    ps
    so
  )

  def change do
    alter table(:languages) do
      add(:rtl, :boolean, default: false, null: false)
    end

    alter table(:revisions) do
      add(:rtl, :boolean)
    end

    languages = Enum.map_join(@rtl_languages, ",", &~s('#{&1}'))

    execute(
      "UPDATE languages SET rtl=TRUE WHERE languages.slug IN (#{languages})",
      ""
    )
  end
end
