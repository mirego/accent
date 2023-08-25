defmodule Accent.Repo.Migrations.AlterOperationsTranslationIdConstraint do
  @moduledoc false
  use Ecto.Migration

  def up do
    execute("""
    ALTER TABLE operations
    DROP CONSTRAINT "operations_translation_id_fkey"
    """)

    execute("""
    ALTER TABLE operations
    ADD CONSTRAINT "operations_translation_id_fkey" FOREIGN KEY ("translation_id") REFERENCES "public"."translations"("id") DEFERRABLE INITIALLY DEFERRED
    """)
  end

  def down do
    execute("""
    ALTER TABLE operations
    DROP CONSTRAINT "operations_translation_id_fkey"
    """)

    execute("""
    ALTER TABLE operations
    ADD CONSTRAINT "operations_translation_id_fkey" FOREIGN KEY ("translation_id") REFERENCES "public"."translations"("id")
    """)
  end
end
