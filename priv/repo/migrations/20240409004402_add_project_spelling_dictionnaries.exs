defmodule Accent.Repo.Migrations.AddProjectSpellingDictionnaries do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:project_lint_entries, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:check_ids, {:array, :string}, null: false, default: [])
      add(:type, :text, null: false)

      add(:value, :text)

      add(:ignore, :boolean, null: false, default: true)
      add(:project_id, references(:projects, type: :uuid), null: false)

      timestamps()
    end

    create(index(:project_lint_entries, [:project_id]))
  end
end
