defmodule Accent.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:email, :string)
      add(:fullname, :string)

      timestamps()
    end

    create table(:auth_providers, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      add(:uid, :text)

      add(:user_id, references(:users, type: :uuid))

      timestamps()
    end

    create table(:auth_applications, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)

      timestamps()
    end

    create table(:auth_access_tokens, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:token, :string)
      add(:user_id, references(:users, type: :uuid))
      add(:auth_application_id, references(:auth_applications, type: :uuid))

      add(:revoked_at, :utc_datetime)

      timestamps()
    end

    create(index(:auth_access_tokens, [:token]))
  end
end
