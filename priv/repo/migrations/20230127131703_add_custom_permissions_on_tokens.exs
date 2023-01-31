defmodule Accent.Repo.Migrations.AddCustomPermissionsOnTokens do
  use Ecto.Migration

  def change do
    alter table(:auth_access_tokens) do
      add(:custom_permissions, {:array, :string})
    end
  end
end
