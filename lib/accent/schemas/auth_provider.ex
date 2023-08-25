defmodule Accent.AuthProvider do
  @moduledoc false
  use Accent.Schema

  schema "auth_providers" do
    field(:name, :string)
    field(:uid, :string)

    belongs_to(:user, Accent.User)

    timestamps()
  end
end
