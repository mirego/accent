defmodule Accent.AccessToken do
  use Accent.Schema

  schema "auth_access_tokens" do
    field(:token, :string)
    field(:global, :boolean)
    field(:revoked_at, :naive_datetime)

    belongs_to(:user, Accent.User)

    timestamps()
  end
end
