defmodule Accent.Repo.Migrations.StandardizeValueTypeColumns do
  use Ecto.Migration

  def change do
    execute("""
      UPDATE "operations" AS o0 SET "previous_translation" = replace(previous_translation::TEXT,'"value_type": ""','"value_type": "string"')::json
    """)

    execute("""
      UPDATE "operations" AS o0 SET "value_type" = 'string' WHERE (o0."value_type" = '')
    """)

    execute("""
      UPDATE "translations" AS o0 SET "value_type" = 'string' WHERE (o0."value_type" = '')
    """)

    execute("""
      UPDATE "translations" AS o0 SET "value_type" = 'string' WHERE (o0."value_type" IS NULL)
    """)

    execute("""
      UPDATE "translations" AS o0 SET "value_type" = 'empty' WHERE (o0."corrected_text" = '')
    """)

    alter table(:translations) do
      modify(:value_type, :string, default: "string", null: false)
    end
  end
end
