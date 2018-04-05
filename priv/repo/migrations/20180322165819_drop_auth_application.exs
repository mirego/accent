defmodule Accent.Repo.Migrations.DropAuthApplication do
  use Ecto.Migration

  def change do
    alter table(:auth_access_tokens) do
      remove :auth_application_id
    end

    drop table(:auth_applications)
  end
end
