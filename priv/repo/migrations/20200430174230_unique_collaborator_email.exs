defmodule Accent.Repo.Migrations.UniqueCollaboratorEmail do
  use Ecto.Migration

  def change do
    execute(
      """
      WITH oldest_email_collaborators AS (
       SELECT email, MIN(inserted_at) as inserted_at
       FROM collaborators
       GROUP BY email
      )
      DELETE FROM collaborators
      WHERE inserted_at > (
       SELECT oldest_email_collaborators.inserted_at
       FROM oldest_email_collaborators
       WHERE collaborators.email  = oldest_email_collaborators.email
      )
      """,
      ""
    )

    create(unique_index(:collaborators, [:email, :project_id]))
  end
end
