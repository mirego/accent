defmodule Accent.Repo.Migrations.AddNonNullableChecks do
  @moduledoc false
  use Ecto.Migration

  def down do
  end

  # credo:disable-for-next-line
  def up do
    drop(constraint(:documents, :documents_project_id_fkey))

    alter table(:documents) do
      modify(:path, :string, null: false)
      modify(:format, :string, null: false)
      modify(:project_id, references(:projects, type: :uuid), null: false)
    end

    alter table(:languages) do
      modify(:name, :string, null: false)
      modify(:slug, :string, null: false)
      modify(:iso_639_1, :string, null: false)
      modify(:iso_639_3, :string, null: false)
      modify(:locale, :string, null: false)
      modify(:android_code, :string, null: false)
      modify(:osx_code, :string, null: false)
      modify(:osx_locale, :string, null: false)
    end

    drop(constraint(:auth_access_tokens, :auth_access_tokens_user_id_fkey))

    alter table(:auth_access_tokens) do
      modify(:token, :string, null: false)
      modify(:user_id, references(:users, type: :uuid), null: false)
    end

    drop(constraint(:auth_providers, :auth_providers_user_id_fkey))

    alter table(:auth_providers) do
      modify(:name, :string, null: false)
      modify(:uid, :string, null: false)
      modify(:user_id, references(:users, type: :uuid), null: false)
    end

    drop(constraint(:collaborators, :collaborators_project_id_fkey))

    alter table(:collaborators) do
      modify(:role, :string, null: false)
      modify(:project_id, references(:projects, type: :uuid), null: false)
    end

    drop(constraint(:comments, :comments_user_id_fkey))

    alter table(:comments) do
      modify(:text, :text, null: false)
      modify(:user_id, references(:users, type: :uuid), null: false)
    end

    alter table(:projects) do
      modify(:name, :string, null: false)
      modify(:locked_file_operations, :boolean, null: false, default: false)
      modify(:sync_lock_version, :integer, null: false, default: 1)
    end

    drop(constraint(:revisions, :revisions_project_id_fkey))
    drop(constraint(:revisions, :revisions_language_id_fkey))

    alter table(:revisions) do
      modify(:project_id, references(:projects, type: :uuid), null: false)
      modify(:language_id, references(:languages, type: :uuid), null: false)
      modify(:master, :boolean, null: false, default: true)
    end

    alter table(:operations) do
      modify(:rollbacked, :boolean, null: false, default: false)
      modify(:batch, :boolean, null: false, default: false)
      modify(:action, :string, null: false)
    end

    alter table(:translations) do
      modify(:key, :string, null: false)
      modify(:removed, :boolean, null: false, default: false)
      modify(:conflicted, :boolean, null: false, default: false)
      modify(:comments_count, :integer, null: false, default: 0)
    end
  end
end
