defmodule Accent.Repo.Migrations.ChangeLengthOfUidForAuthProvider do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:auth_providers) do
      modify(:uid, :string, size: 3000)
    end
  end
end
