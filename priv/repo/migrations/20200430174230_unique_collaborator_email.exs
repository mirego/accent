defmodule Accent.Repo.Migrations.UniqueCollaboratorEmail do
  use Ecto.Migration

  def change do
    execute(
      """
      WITH oldest_email_collaborators AS (
        SELECT
            email,
            project_id,
            MIN(inserted_at) AS
            inserted_at
        FROM
            collaborators
        GROUP BY
            email,
            project_id
        HAVING
            ARRAY_LENGTH(ARRAY_AGG(project_id), 1) > 1
      )
      DELETE FROM
          collaborators
      WHERE
          inserted_at > (
        SELECT
            oldest_email_collaborators.inserted_at
        FROM
            oldest_email_collaborators
        WHERE
            collaborators.email = oldest_email_collaborators.email
            AND collaborators.project_id = oldest_email_collaborators.project_id
      )
      """,
      ""
    )

    create(unique_index(:collaborators, [:email, :project_id]))
  end
end
