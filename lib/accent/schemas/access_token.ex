defmodule Accent.AccessToken do
  @moduledoc false
  use Accent.Schema

  schema "auth_access_tokens" do
    field(:token, :string)
    field(:global, :boolean)
    field(:revoked_at, :naive_datetime)
    field(:custom_permissions, {:array, :string})
    field(:last_used_at, :utc_datetime_usec)

    belongs_to(:user, Accent.User)

    timestamps()
  end
end
